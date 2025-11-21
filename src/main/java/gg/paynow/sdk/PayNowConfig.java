package gg.paynow.sdk;

/**
 * Configuration utility class for creating PayNowClient instances with different setups.
 * 
 * This class provides static factory methods to easily create PayNowClient instances
 * for common use cases.
 */
public class PayNowConfig {
    
    /**
     * Creates a PayNowClient configured for management API operations only.
     * 
     * @param managementApiKey The API key for management operations
     * @return A PayNowClient instance configured for management operations
     */
    public static PayNowClient managementOnly(String managementApiKey) {
        return PayNowClient.forManagement(managementApiKey);
    }
    
    /**
     * Creates a PayNowClient configured for storefront API operations only.
     * 
     * @param storeId The store ID for storefront operations
     * @return A PayNowClient instance configured for storefront operations
     */
    public static PayNowClient storefrontOnly(String storeId) {
        return PayNowClient.forStorefront(storeId);
    }
    
    // Private constructor to prevent instantiation
    private PayNowConfig() {
        throw new UnsupportedOperationException("PayNowConfig is a utility class and cannot be instantiated");
    }
}