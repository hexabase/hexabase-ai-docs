# Billing API

The Billing API manages subscriptions, payment methods, invoices, and usage tracking for organizations. It integrates with Stripe for secure payment processing and provides comprehensive billing management.

## Base URL

All billing endpoints are prefixed with:
```
https://api.hexabase.ai/api/v1/organizations/:orgId/billing
```

## Subscription Object

```json
{
  "id": "sub_1234567890",
  "organization_id": "org-123",
  "plan": "pro",
  "status": "active",
  "current_period_start": "2024-01-01T00:00:00Z",
  "current_period_end": "2024-02-01T00:00:00Z",
  "cancel_at_period_end": false,
  "created_at": "2024-01-01T00:00:00Z",
  "items": [
    {
      "id": "si_1234567890",
      "price_id": "price_pro_monthly",
      "quantity": 5,
      "description": "Pro Plan - Per Workspace",
      "unit_amount": 2900,
      "currency": "usd"
    }
  ],
  "billing_cycle": "monthly",
  "trial_end": null,
  "discount": {
    "coupon": {
      "id": "coupon_startup20",
      "percent_off": 20,
      "duration": "forever"
    }
  }
}
```

## Subscription Management

### Get Subscription

Get current subscription details for an organization.

```http
GET /api/v1/organizations/:orgId/billing/subscription
```

**Response:**
```json
{
  "data": {
    "id": "sub_1234567890",
    "organization_id": "org-123",
    "plan": "pro",
    "status": "active",
    "current_period_start": "2024-01-01T00:00:00Z",
    "current_period_end": "2024-02-01T00:00:00Z",
    "cancel_at_period_end": false,
    "created_at": "2024-01-01T00:00:00Z",
    "items": [
      {
        "id": "si_1234567890",
        "price_id": "price_pro_monthly",
        "quantity": 5,
        "description": "Pro Plan - Per Workspace",
        "unit_amount": 2900,
        "currency": "usd"
      }
    ],
    "next_invoice": {
      "amount_due": 14500,
      "currency": "usd",
      "date": "2024-02-01T00:00:00Z"
    },
    "billing_address": {
      "line1": "123 Business St",
      "city": "San Francisco",
      "state": "CA",
      "postal_code": "94105",
      "country": "US"
    }
  }
}
```

### Create Subscription

Create a new subscription for an organization.

```http
POST /api/v1/organizations/:orgId/billing/subscription
```

**Request Body:**
```json
{
  "price_id": "price_pro_monthly",
  "quantity": 5,
  "payment_method_id": "pm_1234567890",
  "billing_address": {
    "line1": "123 Business St",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94105",
    "country": "US"
  },
  "tax_id": {
    "type": "us_ein",
    "value": "12-3456789"
  },
  "coupon": "STARTUP20",
  "trial_days": 14
}
```

**Response:**
```json
{
  "data": {
    "id": "sub_1234567890",
    "organization_id": "org-123",
    "status": "active",
    "current_period_start": "2024-01-20T10:00:00Z",
    "current_period_end": "2024-02-20T10:00:00Z",
    "trial_end": "2024-02-03T10:00:00Z",
    "items": [
      {
        "price_id": "price_pro_monthly",
        "quantity": 5,
        "unit_amount": 2900
      }
    ]
  }
}
```

### Update Subscription

Update subscription plan, quantity, or billing details.

```http
PUT /api/v1/organizations/:orgId/billing/subscription
```

**Request Body:**
```json
{
  "items": [
    {
      "price_id": "price_pro_monthly",
      "quantity": 10
    }
  ],
  "proration_behavior": "create_prorations",
  "billing_address": {
    "line1": "456 New Business Ave",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94105",
    "country": "US"
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "sub_1234567890",
    "status": "active",
    "updated_at": "2024-01-20T15:00:00Z",
    "items": [
      {
        "price_id": "price_pro_monthly",
        "quantity": 10,
        "unit_amount": 2900
      }
    ],
    "proration_details": {
      "proration_amount": 14500,
      "effective_date": "2024-01-20T15:00:00Z"
    }
  }
}
```

### Cancel Subscription

Cancel a subscription immediately or at the end of the current period.

```http
DELETE /api/v1/organizations/:orgId/billing/subscription
```

**Query Parameters:**
- `immediately` (boolean) - Cancel immediately vs. at period end (default: false)

**Response:**
```json
{
  "data": {
    "id": "sub_1234567890",
    "status": "canceled",
    "canceled_at": "2024-01-20T15:00:00Z",
    "cancel_at_period_end": true,
    "current_period_end": "2024-02-01T00:00:00Z",
    "access_until": "2024-02-01T00:00:00Z"
  }
}
```

## Payment Methods

### List Payment Methods

Get all payment methods for an organization.

```http
GET /api/v1/organizations/:orgId/billing/payment-methods
```

**Response:**
```json
{
  "data": [
    {
      "id": "pm_1234567890",
      "type": "card",
      "card": {
        "brand": "visa",
        "last4": "4242",
        "exp_month": 12,
        "exp_year": 2025,
        "country": "US",
        "funding": "credit"
      },
      "is_default": true,
      "created_at": "2024-01-01T00:00:00Z",
      "billing_details": {
        "name": "John Doe",
        "email": "john@example.com",
        "address": {
          "line1": "123 Business St",
          "city": "San Francisco",
          "state": "CA",
          "postal_code": "94105",
          "country": "US"
        }
      }
    }
  ]
}
```

### Add Payment Method

Add a new payment method to an organization.

```http
POST /api/v1/organizations/:orgId/billing/payment-methods
```

**Request Body:**
```json
{
  "payment_method_id": "pm_1234567890",
  "set_as_default": true,
  "billing_details": {
    "name": "John Doe",
    "email": "john@example.com",
    "address": {
      "line1": "123 Business St",
      "city": "San Francisco",
      "state": "CA",
      "postal_code": "94105",
      "country": "US"
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "id": "pm_1234567890",
    "type": "card",
    "card": {
      "brand": "visa",
      "last4": "4242",
      "exp_month": 12,
      "exp_year": 2025
    },
    "is_default": true,
    "created_at": "2024-01-20T15:00:00Z"
  }
}
```

### Set Default Payment Method

Set a payment method as the default for an organization.

```http
PUT /api/v1/organizations/:orgId/billing/payment-methods/:methodId/default
```

**Response:**
```json
{
  "data": {
    "id": "pm_1234567890",
    "is_default": true,
    "updated_at": "2024-01-20T15:00:00Z"
  }
}
```

### Remove Payment Method

Remove a payment method from an organization.

```http
DELETE /api/v1/organizations/:orgId/billing/payment-methods/:methodId
```

**Response:**
```json
{
  "data": {
    "message": "Payment method removed successfully",
    "payment_method_id": "pm_1234567890"
  }
}
```

## Invoices

### List Invoices

Get billing invoices for an organization.

```http
GET /api/v1/organizations/:orgId/billing/invoices
```

**Query Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Filter by status (`draft`, `open`, `paid`, `void`)
- `since` (string) - Filter by date (ISO 8601)

**Response:**
```json
{
  "data": [
    {
      "id": "in_1234567890",
      "number": "INV-2024-001",
      "status": "paid",
      "amount_due": 14500,
      "amount_paid": 14500,
      "currency": "usd",
      "created_at": "2024-01-01T00:00:00Z",
      "paid_at": "2024-01-05T00:00:00Z",
      "period_start": "2024-01-01T00:00:00Z",
      "period_end": "2024-02-01T00:00:00Z",
      "subtotal": 14500,
      "tax": 0,
      "total": 14500,
      "lines": [
        {
          "description": "Pro Plan - Per Workspace",
          "quantity": 5,
          "unit_amount": 2900,
          "amount": 14500
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 12,
    "pages": 1
  }
}
```

### Get Invoice

Get detailed information about a specific invoice.

```http
GET /api/v1/organizations/:orgId/billing/invoices/:invoiceId
```

**Response:**
```json
{
  "data": {
    "id": "in_1234567890",
    "number": "INV-2024-001",
    "status": "paid",
    "amount_due": 14500,
    "amount_paid": 14500,
    "currency": "usd",
    "created_at": "2024-01-01T00:00:00Z",
    "paid_at": "2024-01-05T00:00:00Z",
    "due_date": "2024-01-31T00:00:00Z",
    "period_start": "2024-01-01T00:00:00Z",
    "period_end": "2024-02-01T00:00:00Z",
    "subtotal": 14500,
    "tax": 0,
    "total": 14500,
    "billing_reason": "subscription_cycle",
    "customer_details": {
      "name": "Acme Corporation",
      "email": "billing@acme.com",
      "address": {
        "line1": "123 Business St",
        "city": "San Francisco",
        "state": "CA",
        "postal_code": "94105",
        "country": "US"
      }
    },
    "lines": [
      {
        "id": "il_1234567890",
        "description": "Pro Plan - Per Workspace",
        "quantity": 5,
        "unit_amount": 2900,
        "amount": 14500,
        "period": {
          "start": "2024-01-01T00:00:00Z",
          "end": "2024-02-01T00:00:00Z"
        }
      }
    ],
    "payment_intent": {
      "id": "pi_1234567890",
      "status": "succeeded",
      "payment_method": {
        "type": "card",
        "card": {
          "brand": "visa",
          "last4": "4242"
        }
      }
    }
  }
}
```

### Download Invoice

Download an invoice as a PDF file.

```http
GET /api/v1/organizations/:orgId/billing/invoices/:invoiceId/download
```

**Response:** PDF file download
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="invoice-INV-2024-001.pdf"
Content-Length: 156743
```

### Get Upcoming Invoice

Get preview of the next invoice for an organization.

```http
GET /api/v1/organizations/:orgId/billing/invoices/upcoming
```

**Response:**
```json
{
  "data": {
    "amount_due": 29000,
    "currency": "usd",
    "period_start": "2024-02-01T00:00:00Z",
    "period_end": "2024-03-01T00:00:00Z",
    "subtotal": 29000,
    "tax": 0,
    "total": 29000,
    "lines": [
      {
        "description": "Pro Plan - Per Workspace",
        "quantity": 10,
        "unit_amount": 2900,
        "amount": 29000,
        "period": {
          "start": "2024-02-01T00:00:00Z",
          "end": "2024-03-01T00:00:00Z"
        }
      }
    ],
    "next_payment_attempt": "2024-02-01T00:00:00Z"
  }
}
```

## Usage Tracking

### Get Current Usage

Get current billing period usage for an organization.

```http
GET /api/v1/organizations/:orgId/billing/usage/current
```

**Response:**
```json
{
  "data": {
    "period_start": "2024-01-01T00:00:00Z",
    "period_end": "2024-02-01T00:00:00Z",
    "days_remaining": 12,
    "workspaces": {
      "included": 5,
      "used": 3,
      "overage": 0,
      "overage_rate": 2900
    },
    "compute_hours": {
      "included": 5000,
      "used": 3247,
      "remaining": 1753,
      "overage": 0,
      "overage_rate": 10
    },
    "storage_gb_hours": {
      "included": 100000,
      "used": 67834,
      "remaining": 32166,
      "overage": 0,
      "overage_rate": 5
    },
    "bandwidth_gb": {
      "included": 1000,
      "used": 234,
      "remaining": 766,
      "overage": 0,
      "overage_rate": 15
    },
    "function_invocations": {
      "included": 1000000,
      "used": 456789,
      "remaining": 543211,
      "overage": 0,
      "overage_rate": 1
    },
    "projected_usage": {
      "workspaces": 3,
      "compute_hours": 5123,
      "storage_gb_hours": 98432,
      "estimated_overage": 0
    }
  }
}
```

## Billing Overview

### Get Billing Overview

Get comprehensive billing overview for an organization.

```http
GET /api/v1/organizations/:orgId/billing/overview
```

**Response:**
```json
{
  "data": {
    "organization_id": "org-123",
    "subscription": {
      "plan": "pro",
      "status": "active",
      "current_period_end": "2024-02-01T00:00:00Z"
    },
    "current_costs": {
      "subscription_fee": 14500,
      "usage_charges": 0,
      "total": 14500,
      "currency": "usd"
    },
    "next_invoice": {
      "amount": 29000,
      "date": "2024-02-01T00:00:00Z",
      "changes": [
        {
          "description": "Workspace quantity increased from 5 to 10",
          "amount_change": 14500
        }
      ]
    },
    "payment_method": {
      "type": "card",
      "last4": "4242",
      "expires": "12/2025"
    },
    "usage_summary": {
      "workspaces": {
        "used": 3,
        "included": 5,
        "percentage": 60
      },
      "compute_hours": {
        "used": 3247,
        "included": 5000,
        "percentage": 65
      }
    },
    "cost_trends": {
      "last_6_months": [
        {
          "month": "2023-08",
          "amount": 14500
        },
        {
          "month": "2023-09",
          "amount": 14500
        }
      ],
      "average_monthly": 14500,
      "trend": "stable"
    }
  }
}
```

## Billing Settings

### Get Billing Settings

Get billing configuration and preferences.

```http
GET /api/v1/organizations/:orgId/billing/settings
```

**Response:**
```json
{
  "data": {
    "organization_id": "org-123",
    "currency": "usd",
    "timezone": "America/New_York",
    "billing_email": "billing@acme.com",
    "invoice_settings": {
      "days_until_due": 30,
      "footer": "Thank you for your business!",
      "auto_advance": true
    },
    "notifications": {
      "invoice_created": true,
      "payment_succeeded": false,
      "payment_failed": true,
      "subscription_updated": true,
      "usage_alerts": {
        "enabled": true,
        "thresholds": {
          "workspace_limit_80": true,
          "compute_hours_90": true,
          "overage_charges": true
        }
      }
    },
    "tax_settings": {
      "tax_id": {
        "type": "us_ein",
        "value": "12-3456789"
      },
      "tax_exempt": false
    }
  }
}
```

### Update Billing Settings

Update billing configuration and preferences.

```http
PUT /api/v1/organizations/:orgId/billing/settings
```

**Request Body:**
```json
{
  "billing_email": "accounting@acme.com",
  "timezone": "America/Los_Angeles",
  "invoice_settings": {
    "days_until_due": 15,
    "footer": "Payment terms: Net 15 days"
  },
  "notifications": {
    "payment_succeeded": true,
    "usage_alerts": {
      "thresholds": {
        "workspace_limit_80": true,
        "compute_hours_80": true,
        "storage_90": true
      }
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "organization_id": "org-123",
    "billing_email": "accounting@acme.com",
    "timezone": "America/Los_Angeles",
    "updated_at": "2024-01-20T15:00:00Z",
    "invoice_settings": {
      "days_until_due": 15,
      "footer": "Payment terms: Net 15 days"
    }
  }
}
```

## Plans

### List Plans

Get all available billing plans.

```http
GET /api/v1/plans
```

**Response:**
```json
{
  "data": [
    {
      "id": "plan_free",
      "name": "Free",
      "description": "Perfect for getting started",
      "price": 0,
      "currency": "usd",
      "interval": "month",
      "features": [
        "1 workspace",
        "100 compute hours/month",
        "5GB storage",
        "Community support"
      ],
      "limits": {
        "workspaces": 1,
        "compute_hours": 100,
        "storage_gb": 5,
        "team_members": 3,
        "api_calls_per_hour": 1000
      }
    },
    {
      "id": "plan_pro",
      "name": "Pro",
      "description": "For growing teams and production workloads",
      "price": 2900,
      "currency": "usd",
      "interval": "month",
      "unit": "workspace",
      "features": [
        "Unlimited workspaces",
        "5,000 compute hours/month included",
        "100GB storage included",
        "Priority support",
        "Advanced monitoring",
        "Backup & restore"
      ],
      "limits": {
        "workspaces": null,
        "compute_hours": 5000,
        "storage_gb": 100,
        "team_members": null,
        "api_calls_per_hour": 10000
      },
      "overage_pricing": {
        "compute_hours": 10,
        "storage_gb_hours": 5,
        "bandwidth_gb": 15
      }
    }
  ]
}
```

### Compare Plans

Get a detailed comparison of available plans.

```http
GET /api/v1/plans/compare
```

**Query Parameters:**
- `plans` (string) - Comma-separated plan IDs to compare

**Response:**
```json
{
  "data": {
    "comparison": [
      {
        "feature": "Workspaces",
        "free": "1",
        "pro": "Unlimited",
        "enterprise": "Unlimited"
      },
      {
        "feature": "Compute Hours",
        "free": "100/month",
        "pro": "5,000/month + overage",
        "enterprise": "Custom"
      },
      {
        "feature": "Storage",
        "free": "5GB",
        "pro": "100GB + overage",
        "enterprise": "Custom"
      },
      {
        "feature": "Support",
        "free": "Community",
        "pro": "Priority",
        "enterprise": "Dedicated"
      }
    ],
    "recommended": "pro"
  }
}
```

## Webhooks

### Handle Stripe Webhook

Process Stripe webhook events for billing updates.

```http
POST /webhooks/stripe
```

**Headers:**
- `Stripe-Signature` - Webhook signature for verification

**Supported Events:**
- `invoice.payment_succeeded`
- `invoice.payment_failed`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `payment_method.attached`

**Response:**
```json
{
  "received": true
}
```

## Error Responses

### 400 Bad Request - Invalid Payment Method
```json
{
  "error": {
    "code": "INVALID_PAYMENT_METHOD",
    "message": "The payment method is invalid or expired",
    "details": {
      "payment_method_id": "pm_1234567890",
      "decline_code": "expired_card"
    }
  }
}
```

### 402 Payment Required - Subscription Past Due
```json
{
  "error": {
    "code": "SUBSCRIPTION_PAST_DUE",
    "message": "Subscription has unpaid invoices",
    "details": {
      "subscription_id": "sub_1234567890",
      "amount_due": 14500,
      "invoice_id": "in_1234567890"
    }
  }
}
```

### 409 Conflict - Plan Change Not Allowed
```json
{
  "error": {
    "code": "PLAN_CHANGE_RESTRICTED",
    "message": "Cannot downgrade plan while usage exceeds new limits",
    "details": {
      "current_plan": "pro",
      "requested_plan": "free",
      "blocking_usage": {
        "workspaces": {
          "current": 5,
          "limit": 1
        }
      }
    }
  }
}
```

## Webhooks

Billing events that trigger webhooks:

- `billing.subscription.created`
- `billing.subscription.updated`
- `billing.subscription.canceled`
- `billing.invoice.created`
- `billing.invoice.paid`
- `billing.invoice.payment_failed`
- `billing.payment_method.added`
- `billing.payment_method.removed`
- `billing.usage.threshold_exceeded`

## Best Practices

1. **Payment Methods**: Always maintain a valid default payment method
2. **Usage Monitoring**: Set up alerts for usage thresholds to avoid surprises
3. **Invoice Management**: Download and archive invoices for accounting
4. **Plan Optimization**: Regularly review usage patterns and adjust plans
5. **Security**: Use webhook signatures to verify billing events