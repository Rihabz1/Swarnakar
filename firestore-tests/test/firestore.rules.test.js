import { readFileSync } from "node:fs";
import { after, before, beforeEach, describe, test } from "node:test";
import assert from "node:assert/strict";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  updateDoc,
} from "firebase/firestore";

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "swarnakar-test",
    firestore: {
      rules: readFileSync("../firestore.rules", "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

beforeEach(async () => env.clearFirestore());
after(async () => env.cleanup());

const guestDb = () => env.unauthenticatedContext().firestore();
const userDb = (uid) => env.authenticatedContext(uid).firestore();
const adminDb = () =>
  env.authenticatedContext("admin-user", { admin: true }).firestore();

async function seed(path, data) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

describe("public market reference data", () => {
  test("anyone can read current prices and nisab", async () => {
    await seed("prices/current", { gold_22k: 248000 });
    await seed("zakat/nisab", { silver_nisab: 52860 });
    await assertSucceeds(getDoc(doc(guestDb(), "prices/current")));
    await assertSucceeds(getDoc(doc(guestDb(), "zakat/nisab")));
  });

  test("ordinary and unauthenticated clients cannot change prices", async () => {
    await assertFails(setDoc(doc(guestDb(), "prices/current"), { gold_22k: 1 }));
    await assertFails(setDoc(doc(userDb("user-a"), "prices/current"), { gold_22k: 1 }));
  });

  test("admin claim can update prices and nisab", async () => {
    await assertSucceeds(setDoc(doc(adminDb(), "prices/current"), { gold_22k: 1 }));
    await assertSucceeds(setDoc(doc(adminDb(), "zakat/nisab"), { silver_nisab: 1 }));
  });
});

describe("user isolation", () => {
  const safeUser = {
    uid: "user-a",
    name: "A",
    shopName: "",
    address: "",
    isSubscribed: false,
    plan: "",
    subExpires: null,
  };

  test("authenticated user can create a safe profile under own uid", async () => {
    await assertSucceeds(setDoc(doc(userDb("user-a"), "users/user-a"), safeUser));
  });

  test("user cannot create another user's profile", async () => {
    await assertFails(setDoc(doc(userDb("user-a"), "users/user-b"), { ...safeUser, uid: "user-b" }));
  });

  test("client profile creation rejects password hashes and paid entitlement", async () => {
    await assertFails(setDoc(doc(userDb("user-a"), "users/user-a"), { ...safeUser, passwordHash: "hash" }));
    await assertFails(setDoc(doc(userDb("user-a"), "users/user-a"), { ...safeUser, isSubscribed: true }));
  });

  test("user can read own profile but not another profile", async () => {
    await seed("users/user-a", safeUser);
    await seed("users/user-b", { ...safeUser, uid: "user-b" });
    await assertSucceeds(getDoc(doc(userDb("user-a"), "users/user-a")));
    await assertFails(getDoc(doc(userDb("user-a"), "users/user-b")));
  });

  test("user can edit profile fields but cannot grant subscription", async () => {
    await seed("users/user-a", safeUser);
    await assertSucceeds(updateDoc(doc(userDb("user-a"), "users/user-a"), { name: "Updated" }));
    await assertFails(updateDoc(doc(userDb("user-a"), "users/user-a"), { isSubscribed: true }));
  });

  test("owner can delete own profile", async () => {
    await seed("users/user-a", safeUser);
    await assertSucceeds(deleteDoc(doc(userDb("user-a"), "users/user-a")));
  });
});

describe("reports and default deny", () => {
  test("owner can create and read a structurally valid report", async () => {
    const report = { type: "gold", item: "22k", date: "2026-01-01", value: "100" };
    const reference = doc(userDb("user-a"), "users/user-a/reports/report-1");
    await assertSucceeds(setDoc(reference, report));
    await assertSucceeds(getDoc(reference));
  });

  test("another user cannot access the owner's report", async () => {
    await seed("users/user-a/reports/report-1", { type: "gold", item: "22k", date: "x", value: "1" });
    await assertFails(getDoc(doc(userDb("user-b"), "users/user-a/reports/report-1")));
  });

  test("unknown collections are denied", async () => {
    await assertFails(getDoc(doc(guestDb(), "private/secret")));
    await assertFails(setDoc(doc(adminDb(), "unknown/doc"), { value: true }));
  });
});
