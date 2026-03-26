#!/usr/bin/env bash
#
# Pre-processes the storefront OpenAPI spec by merging in the undocumented
# /v1/webstores/{storeId}/modules/prepared endpoint and all required schemas.
#
# This endpoint returns pre-assembled storefront modules (recent payments,
# payment goals, top customers, etc.) and is used by the headless template
# but is not part of the official API spec.
#
# Usage: ./scripts/preprocess-storefront-spec.sh [output-path]
#   output-path  defaults to build/storefront-api-merged.json
#
# Requires: curl, jq (jq is auto-downloaded if missing)
#
set -euo pipefail

# Auto-install jq if not available
if ! command -v jq &>/dev/null; then
  echo "[preprocess] jq not found, downloading static binary..."
  JQ_BIN="${TMPDIR:-/tmp}/jq"
  curl -sS -L -o "$JQ_BIN" "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64"
  chmod +x "$JQ_BIN"
  export PATH="$(dirname "$JQ_BIN"):$PATH"
  echo "[preprocess] jq installed to $JQ_BIN"
fi

STOREFRONT_URL="https://api.paynow.gg/swagger/storefront-api/openapi.json"
MANAGEMENT_URL="https://api.paynow.gg/swagger/management-api/openapi.json"

OUTPUT="${1:-build/storefront-api-merged.json}"

mkdir -p "$(dirname "$OUTPUT")"

echo "[preprocess] Downloading storefront spec..."
STOREFRONT_SPEC=$(curl -sS "$STOREFRONT_URL")

echo "[preprocess] Downloading management spec..."
MANAGEMENT_SPEC=$(curl -sS "$MANAGEMENT_URL")

# Schemas to copy from management spec that don't exist in storefront.
# These are needed by OrderDto which is referenced by the modules/prepared response.
SCHEMAS_FROM_MANAGEMENT=(
  "OrderDto"
  "OrderLineDto"
  "OrderStatus"
  "OrderType"
  "OrderLinePayoutSplitDto"
  "CustomVariableLineItemDto"
  "LastPaymentErrorDto"
  "PaymentDeclineCode"
  "SalesTaxJurisdictionDto"
  "SalesTaxJurisdictionTaxDto"
)

echo "[preprocess] Extracting ${#SCHEMAS_FROM_MANAGEMENT[@]} schemas from management spec..."

# Build a jq filter to extract multiple schemas at once
EXTRACT_FILTER=".components.schemas | { "
for i in "${!SCHEMAS_FROM_MANAGEMENT[@]}"; do
  name="${SCHEMAS_FROM_MANAGEMENT[$i]}"
  if [ "$i" -gt 0 ]; then
    EXTRACT_FILTER+=", "
  fi
  EXTRACT_FILTER+="\"${name}\": .\"${name}\""
done
EXTRACT_FILTER+=" }"

MANAGEMENT_SCHEMAS=$(echo "$MANAGEMENT_SPEC" | jq "$EXTRACT_FILTER")

echo "[preprocess] Merging schemas and adding modules endpoint..."

# The main jq transformation:
# 1. Merge management schemas into storefront schemas
# 2. Add module-specific schemas (settings DTOs, module wrapper)
# 3. Add the /v1/webstores/{storeId}/modules/prepared path
# 4. Add the "modules" tag
jq --argjson mgmt_schemas "$MANAGEMENT_SCHEMAS" '

# --- New schemas for the modules feature ---

# Module settings types
.components.schemas.PaymentGoalModuleSettingsDto = {
  "type": "object",
  "description": "Settings for the payment goal module.",
  "required": ["header", "period", "barStyle", "goalTarget", "animateGoalBar", "allowPercentageOverflow", "displayAbsoluteGoalAmount"],
  "properties": {
    "header": { "type": "string", "description": "The header text displayed above the payment goal." },
    "period": { "type": "string", "description": "The time period for the goal (e.g. daily, weekly, monthly)." },
    "barStyle": { "type": "string", "description": "The visual style of the goal progress bar." },
    "goalTarget": { "type": "integer", "format": "int64", "description": "The target amount for the payment goal in smallest currency unit." },
    "animateGoalBar": { "type": "boolean", "description": "Whether the goal bar should be animated." },
    "allowPercentageOverflow": { "type": "boolean", "description": "Whether to allow the progress bar to exceed 100%." },
    "displayAbsoluteGoalAmount": { "type": "boolean", "description": "Whether to show the absolute goal amount instead of percentage." }
  },
  "additionalProperties": false
} |

.components.schemas.RecentPaymentsModuleSettingsDto = {
  "type": "object",
  "description": "Settings for the recent payments module.",
  "required": ["header", "displayLimit", "displayFreePayments", "displayTimeOfPurchase", "displayPriceOfPurchase", "displayPurchasedProduct"],
  "properties": {
    "header": { "type": "string", "description": "The header text displayed above the recent payments list." },
    "displayLimit": { "type": "integer", "format": "int32", "description": "The maximum number of recent payments to display." },
    "displayFreePayments": { "type": "boolean", "description": "Whether to include free (zero-amount) payments." },
    "displayTimeOfPurchase": { "type": "boolean", "description": "Whether to show the time of each purchase." },
    "displayPriceOfPurchase": { "type": "boolean", "description": "Whether to show the price of each purchase." },
    "displayPurchasedProduct": { "type": "boolean", "description": "Whether to show the purchased product name." }
  },
  "additionalProperties": false
} |

.components.schemas.TopCustomerModuleSettingsDto = {
  "type": "object",
  "description": "Settings for the top customer module.",
  "required": ["header", "field", "limit", "period", "displayCustomerSpendAmount"],
  "properties": {
    "header": { "type": "string", "description": "The header text displayed above the top customers list." },
    "field": { "type": "string", "description": "The field to rank customers by." },
    "limit": { "type": "integer", "format": "int32", "description": "The maximum number of top customers to display." },
    "period": { "type": "string", "description": "The time period for ranking (e.g. daily, weekly, monthly)." },
    "displayCustomerSpendAmount": { "type": "boolean", "description": "Whether to show how much each customer has spent." }
  },
  "additionalProperties": false
} |

.components.schemas.GiftCardBalanceModuleSettingsDto = {
  "type": "object",
  "description": "Settings for the gift card balance module.",
  "required": ["header"],
  "properties": {
    "header": { "type": "string", "description": "The header text displayed above the gift card balance lookup." }
  },
  "additionalProperties": false
} |

.components.schemas.TextBoxModuleSettingsDto = {
  "type": "object",
  "description": "Settings for the text box module.",
  "required": ["header", "content"],
  "properties": {
    "header": { "type": "string", "description": "The header text displayed above the text box." },
    "content": { "type": "string", "description": "The content of the text box. May contain HTML or markdown." }
  },
  "additionalProperties": false
} |

# Module type — defined as a plain string to avoid openapi-generator 3.1.x enum bugs.
# Known values: payment_goal, recent_payments, top_customer, giftcard_balance, text_box

# Module data wrapper — uses a generic settings object since the type varies
.components.schemas.ModuleDataDto = {
  "type": "object",
  "description": "The data payload for a storefront module, containing settings and optional order/revenue data.",
  "properties": {
    "settings": {
      "type": "object",
      "description": "Module-specific settings. The shape depends on the module type: PaymentGoalModuleSettingsDto, RecentPaymentsModuleSettingsDto, TopCustomerModuleSettingsDto, GiftCardBalanceModuleSettingsDto, or TextBoxModuleSettingsDto.",
      "additionalProperties": true
    },
    "orders": {
      "type": "array",
      "items": { "$ref": "#/components/schemas/OrderDto" },
      "description": "Recent orders, present for recent_payments and top_customer modules."
    },
    "revenue": {
      "type": "string",
      "description": "Revenue amount string, present for payment_goal modules."
    }
  },
  "additionalProperties": false
} |

# The top-level module object
.components.schemas.ModuleDto = {
  "type": "object",
  "description": "Represents a configured storefront module (e.g. recent payments, payment goal, top customers).",
  "required": ["id", "data"],
  "properties": {
    "id": {
      "type": "string",
      "description": "The type of storefront module. Known values: payment_goal, recent_payments, top_customer, giftcard_balance, text_box."
    },
    "data": {
      "$ref": "#/components/schemas/ModuleDataDto"
    }
  },
  "additionalProperties": false
} |

# --- Merge management schemas ---
.components.schemas += $mgmt_schemas |

# --- Add the modules tag ---
.tags += [{ "name": "modules" }] |

# --- Add the endpoint ---
.paths["/v1/webstores/{storeId}/modules/prepared"] = {
  "get": {
    "tags": ["modules"],
    "summary": "Get prepared modules",
    "description": "Retrieves all configured storefront modules for the given webstore, with data pre-assembled server-side. This includes modules like recent payments, payment goals, top customers, gift card balance lookup, and text boxes. No authentication is required.",
    "operationId": "StorefrontModules_GetPreparedModules",
    "parameters": [
      {
        "name": "storeId",
        "in": "path",
        "description": "The webstore ID.",
        "required": true,
        "schema": {
          "$ref": "#/components/schemas/FlakeId"
        }
      }
    ],
    "responses": {
      "200": {
        "description": "OK",
        "content": {
          "application/json": {
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/components/schemas/ModuleDto"
              }
            }
          }
        }
      },
      "default": {
        "description": "Error response",
        "content": {
          "application/json": {
            "schema": {
              "$ref": "#/components/schemas/PayNowError"
            }
          }
        }
      }
    },
    "security": [
      {}
    ]
  }
}

' <<< "$STOREFRONT_SPEC" > "$OUTPUT"

echo "[preprocess] Merged spec written to $OUTPUT"
echo "[preprocess] Done."
