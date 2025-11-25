# PayNow Java SDK

A Java SDK for the [PayNow.gg API](https://paynow.gitbook.io/paynow-api)

## Installation 

### Maven

Add JitPack repository to your `pom.xml`:

```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```

Add the dependency:

```xml
<dependency>
    <groupId>com.github.InstantlyMoist</groupId>
    <artifactId>java-sdk</artifactId>
    <version>Tag</version>
</dependency>
```

### Gradle

Add JitPack repository to your `build.gradle`:

```gradle
repositories {
    maven { url 'https://jitpack.io' }
}
```

Add the dependency:

```gradle
dependencies {
    implementation 'com.github.InstantlyMoist:java-sdk:Tag'
}
```

## Quick Start

### Basic Storefront Usage (Public API)

```java
import gg.paynow.sdk.PayNowClient;
import gg.paynow.sdk.storefront.api.ProductsApi;
import gg.paynow.sdk.storefront.client.ApiException;
import gg.paynow.sdk.storefront.model.StorefrontProductDto;

private static final String STORE_ID = "411486491630370816";
private static final PayNowClient client = PayNowClient.forStorefront(STORE_ID);

public static void main(String[] args) throws ApiException {
    ProductsApi productsApi = client.getStorefrontApi(ProductsApi.class);

    List<StorefrontProductDto> products = productsApi
            .getStorefrontProducts(STORE_ID, null, null, null, null);
    System.out.println(products);
}
```

### Authenticated Storefront Usage (Protected API)

Some API endpoints require customer authentication (like cart operations). You can add authentication in several ways:

#### Option 1: Create client with authentication

```java
import gg.paynow.sdk.PayNowClient;
import gg.paynow.sdk.storefront.api.CartApi;
import gg.paynow.sdk.storefront.client.ApiException;
import gg.paynow.sdk.storefront.model.CartDto;

private static final String STORE_ID = "411486491630370816";
private static final String CUSTOMER_AUTH_TOKEN = "your-jwt-token-here";

public static void main(String[] args) throws ApiException {
    // Create client with authentication
    PayNowClient client = PayNowClient.forStorefrontWithAuth(STORE_ID, CUSTOMER_AUTH_TOKEN);
    
    CartApi cartApi = client.getStorefrontApi(CartApi.class);
    CartDto cart = cartApi.getCart(null, null, null);
    System.out.println(cart);
}
```

#### Option 2: Add authentication to existing client

```java
import gg.paynow.sdk.PayNowClient;
import gg.paynow.sdk.storefront.api.CartApi;

public static void main(String[] args) throws ApiException {
    PayNowClient client = PayNowClient.forStorefront(STORE_ID);
    
    // Add authentication later
    client.setStorefrontAuth(CUSTOMER_AUTH_TOKEN);
    
    CartApi cartApi = client.getStorefrontApi(CartApi.class);
    CartDto cart = cartApi.getCart(null, null, null);
    System.out.println(cart);
}
```

#### Option 3: Using PayNowConfig for convenience

```java
import gg.paynow.sdk.PayNowConfig;
import gg.paynow.sdk.storefront.api.CartApi;

public static void main(String[] args) throws ApiException {
    // Using convenience factory methods
    PayNowClient client = PayNowConfig.storefrontWithAuth(STORE_ID, CUSTOMER_AUTH_TOKEN);
    
    CartApi cartApi = client.getStorefrontApi(CartApi.class);
    CartDto cart = cartApi.getCart(null, null, null);
    System.out.println(cart);
}
```

### Management API Usage

```java
import gg.paynow.sdk.PayNowClient;
import gg.paynow.sdk.management.api.ProductsApi;
import gg.paynow.sdk.management.client.ApiException;

private static final String MANAGEMENT_API_KEY = "your-management-api-key";

public static void main(String[] args) throws ApiException {
    PayNowClient client = PayNowClient.forManagement(MANAGEMENT_API_KEY);
    
    ProductsApi productsApi = client.getManagementApi(ProductsApi.class);
    // Use management API methods...
}
```

For issues with the SDK, please open an issue on GitHub.
For PayNow API documentation and support, visit the PayNow developer portal.

## PayNow.gg Support

For support, questions, or more information, join our Discord community:

- [Discord](https://discord.com/invite/paynow)

## Contributing

Contributions are welcome! If you'd like to improve the SDK or suggest new features, please fork the repository, make your changes, and submit a pull request.