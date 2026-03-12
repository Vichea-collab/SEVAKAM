import { Router } from "express";
import { requireAuth } from "../middlewares/auth.middleware.js";
import { requireRole } from "../middlewares/role.middleware.js";
import SubscriptionController from "../controllers/subscription.controller.js";
import express from "express";

const router = Router();

// Subscription status
router.get(
  "/status",
  requireAuth,
  requireRole(["provider"]),
  SubscriptionController.getStatus,
);

// Create Stripe Checkout session
router.post(
  "/checkout",
  requireAuth,
  requireRole(["provider"]),
  SubscriptionController.createCheckout,
);

// Cancel subscription
router.post(
  "/cancel",
  requireAuth,
  requireRole(["provider"]),
  SubscriptionController.cancel,
);

// Verify checkout session (fallback for when webhooks can't reach the server)
router.post(
  "/verify",
  requireAuth,
  requireRole(["provider"]),
  SubscriptionController.verifyCheckout,
);

// Stripe webhook (raw body required, no auth)
router.post(
  "/webhook",
  express.raw({ type: "application/json" }),
  SubscriptionController.webhook,
);

export default router;
