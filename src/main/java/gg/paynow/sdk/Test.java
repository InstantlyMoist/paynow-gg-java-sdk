package gg.paynow.sdk;

import gg.paynow.sdk.storefront.api.ProductsApi;
import gg.paynow.sdk.storefront.client.ApiException;
import gg.paynow.sdk.storefront.model.StorefrontProductDto;

import java.util.List;

public class Test {

    private static final String STORE_ID = "484424470996459520";
    private static final PayNowClient client = PayNowClient.forStorefront(STORE_ID);

    public static void main(String[] args) throws ApiException {
        ProductsApi productsApi = client.getStorefrontApi(ProductsApi.class);

        List<StorefrontProductDto> products = productsApi
                .getStorefrontProducts(STORE_ID, null, null, null, null);
        System.out.println(products);
    }
}