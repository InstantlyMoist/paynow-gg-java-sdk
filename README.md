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

```java
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

For issues with the SDK, please open an issue on GitHub.
For PayNow API documentation and support, visit the PayNow developer portal.

## PayNow.gg Support

For support, questions, or more information, join our Discord community:

- [Discord](https://discord.com/invite/paynow)

## Contributing

Contributions are welcome! If you'd like to improve the SDK or suggest new features, please fork the repository, make your changes, and submit a pull request.