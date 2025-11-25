package gg.paynow.sdk;

import gg.paynow.sdk.management.client.ApiClient;
import java.lang.reflect.Constructor;

public class PayNowClient {
    private final ApiClient managementClient;
    private final gg.paynow.sdk.storefront.client.ApiClient storefrontClient;
    
    // Private constructor - use static factory methods instead
    private PayNowClient(ApiClient managementClient, gg.paynow.sdk.storefront.client.ApiClient storefrontClient) {
        this.managementClient = managementClient;
        this.storefrontClient = storefrontClient;
    }
    
    /**
     * Creates a PayNowClient for management API operations only.
     * 
     * @param apiKey The management API key
     * @return A PayNowClient configured for management operations
     */
    public static PayNowClient forManagement(String apiKey) {
        return new PayNowClient(createManagementClient(apiKey), null);
    }
    
    /**
     * Creates a PayNowClient for storefront API operations only.
     * 
     * @param storeId The storefront store ID
     * @return A PayNowClient configured for storefront operations
     */
    public static PayNowClient forStorefront(String storeId) {
        return new PayNowClient(null, createStorefrontClient(storeId));
    }
    
    /**
     * Creates a PayNowClient for storefront API operations with customer authentication.
     * 
     * @param storeId The storefront store ID
     * @param customerAuthToken The customer authentication token (JWT or similar)
     * @return A PayNowClient configured for storefront operations with authentication
     */
    public static PayNowClient forStorefrontWithAuth(String storeId, String customerAuthToken) {
        return new PayNowClient(null, createStorefrontClientWithAuth(storeId, customerAuthToken));
    }
    
    private static ApiClient createManagementClient(String apiKey) {
        ApiClient client = new ApiClient();
        client.setApiKey(apiKey);
        client.setBasePath("https://api.paynow.gg");
        return client;
    }
    
    private static gg.paynow.sdk.storefront.client.ApiClient createStorefrontClient(String storeId) {
        gg.paynow.sdk.storefront.client.ApiClient client = new gg.paynow.sdk.storefront.client.ApiClient();
        client.setBasePath("https://api.paynow.gg");
        
        // Set the store ID as a default header for all storefront API calls
        if (storeId != null && !storeId.trim().isEmpty()) {
            client.addDefaultHeader("x-paynow-store-id", storeId);
        }
        
        return client;
    }
    
    private static gg.paynow.sdk.storefront.client.ApiClient createStorefrontClientWithAuth(String storeId, String customerAuthToken) {
        gg.paynow.sdk.storefront.client.ApiClient client = new gg.paynow.sdk.storefront.client.ApiClient();
        client.setBasePath("https://api.paynow.gg");
        
        // Set the store ID as a default header for all storefront API calls
        if (storeId != null && !storeId.trim().isEmpty()) {
            client.addDefaultHeader("x-paynow-store-id", storeId);
        }
        
        // Set the customer authentication token
        if (customerAuthToken != null && !customerAuthToken.trim().isEmpty()) {
            client.addDefaultHeader("Authorization", customerAuthToken);
        }
        
        return client;
    }
    
    /**
     * Creates an instance of the specified Management API class.
     * 
     * @param <T> The type of the API class
     * @param apiClass The API class to instantiate
     * @return A new instance of the API class
     * @throws RuntimeException if the management client is not configured or instantiation fails
     */
    public <T> T getManagementApi(Class<T> apiClass) {
        if (managementClient == null) {
            throw new RuntimeException("Management client not configured. Provide a management API key.");
        }
        
        try {
            Constructor<T> constructor = apiClass.getConstructor(ApiClient.class);
            return constructor.newInstance(managementClient);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create management API instance: " + apiClass.getSimpleName(), e);
        }
    }
    
    /**
     * Creates an instance of the specified Storefront API class.
     * 
     * @param <T> The type of the API class
     * @param apiClass The API class to instantiate
     * @return A new instance of the API class
     * @throws RuntimeException if the storefront client is not configured or instantiation fails
     */
    public <T> T getStorefrontApi(Class<T> apiClass) {
        if (storefrontClient == null) {
            throw new RuntimeException("Storefront client not configured. Provide a storefront token.");
        }
        
        try {
            Constructor<T> constructor = apiClass.getConstructor(gg.paynow.sdk.storefront.client.ApiClient.class);
            return constructor.newInstance(storefrontClient);
        } catch (Exception e) {
            throw new RuntimeException("Failed to create storefront API instance: " + apiClass.getSimpleName(), e);
        }
    }
    
    /**
     * Gets the underlying management API client for advanced configuration.
     * 
     * @return The management ApiClient instance, or null if not configured
     */
    public ApiClient getManagementClient() {
        return managementClient;
    }
    
    /**
     * Gets the underlying storefront API client for advanced configuration.
     * 
     * @return The storefront ApiClient instance, or null if not configured
     */
    public gg.paynow.sdk.storefront.client.ApiClient getStorefrontClient() {
        return storefrontClient;
    }
    
    /**
     * Sets the customer authorization token for storefront operations.
     * This allows adding authentication to an existing storefront client.
     * 
     * @param customerAuthToken The customer authentication token (JWT or similar)
     * @throws RuntimeException if the storefront client is not configured
     */
    public void setStorefrontAuth(String customerAuthToken) {
        if (storefrontClient == null) {
            throw new RuntimeException("Storefront client not configured. Create a storefront client first.");
        }
        
        if (customerAuthToken != null && !customerAuthToken.trim().isEmpty()) {
            storefrontClient.addDefaultHeader("Authorization", customerAuthToken);
        }
    }
}