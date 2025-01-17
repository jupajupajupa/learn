You can investigate the solution while the script continues to deploy the Docker containers to Azure Kubernetes Service (AKS). While doing so, the script will continue to run.

## Review code

Review the directories in the explorer pane in the IDE. Relative to the workspace root, the files for this module are located in *modules/microservices-aspnet-core*. 

> [!IMPORTANT]
> For brevity, all directory paths described in this module are relative to the *modules/microservices-aspnet-core* directory.

The following subdirectories located in *src* contain .NET projects, each of which is containerized and deployed to AKS:

| Project directory | Description |
|-------------------|-------------|
| *:::no-loc text="Aggregators/":::* | Services to aggregate across multiple microservices for certain cross-service operations. An HTTP aggregator is implemented in the *:::no-loc text="ApiGateways/Aggregators/Web.Shopping.HttpAggregator":::* project. |
| *:::no-loc text="BuildingBlocks/":::* | Services that provide cross-cutting functionality, such as the app's event bus used for inter-service events. |
| *:::no-loc text="Services/":::* | These projects implement the business logic of the app. Each microservice is autonomous, with its own data store. They showcase different software patterns, including Create-Read-Update-Delete (CRUD), Domain-Driven Design (DDD), and Command and Query Responsibility Segregation (CQRS). The new *:::no-loc text="Coupon.API":::* project has been provided, but it's incomplete. |
| *:::no-loc text="Web/":::* | ASP.NET Core apps that implement user interfaces. *:::no-loc text="WebSPA":::* is a storefront UI built with Angular. *:::no-loc text="WebStatus":::* is the health checks dashboard for monitoring the operational status of each service. |

## Verify deployment to AKS

After the app has deployed to AKS, you'll see a variation of the following message in the terminal:

```console
The eShop-Learn application has been deployed.

You can begin exploring these services (when available):
- Centralized logging       : http://13.83.97.100/seq/#/events?autorefresh (See transient failures during startup)
- General application status: http://13.83.97.100/webstatus/ (See overall service status)
- Web SPA application       : http://13.83.97.100/
```

> [!TIP]
> This output can be found in *modules/microservices-aspnet-core/deployment-urls.txt*.

Even though the app has been deployed, it might take a few minutes to come online. Verify that the app is deployed and online with the following steps:

1. Select the **General application status** link in the terminal to view the *:::no-loc text="WebStatus":::* health checks dashboard. The resulting page displays the status of each microservice in the deployment. The page is designed to refresh automatically, every 10 seconds.

    > [!IMPORTANT]
    > If the WebStatus isn't automatically refreshing, it's due to an issue with the container image used for WebStatus. To work around the issue, manually refresh the WebStatus page periodically.

    :::image type="content" source="../media/4-review-code-verify-deployment/health-check.png" alt-text="Health check page." border="true" lightbox="../media/4-review-code-verify-deployment/health-check.png":::

    > [!NOTE]
    > While the app is starting up, you might initially receive an HTTP 503 response from the server. Retry after a few seconds. The Seq logs, which are viewable at the **Centralized logging** URL, are available before the other endpoints.

1. After all the services are healthy, select the **Web SPA application** link in the terminal to test the *:::no-loc text="eShopOnContainers":::* web app. The following page appears:

    :::image type="content" source="../../media/microservices/eshop-spa.png" alt-text="eShop single page app." border="true" lightbox="../../media/microservices/eshop-spa.png":::

1. Complete a purchase as follows:
    1. Select the **LOGIN** link in the upper right to sign into the app. The credentials are provided on the page.
    1. Add the **.NET BLUE HOODIE** to the shopping bag by selecting the image.
    1. Select the shopping bag icon in the upper right.
    1. Select **CHECKOUT**, and then select **PLACE ORDER** to complete the purchase.

    :::image type="content" source="../../media/microservices/eshop-spa-shopping-bag.png" alt-text="shopping cart with .NET Blue Hoodie." border="true" lightbox="../../media/microservices/eshop-spa-shopping-bag.png":::

In this unit, you've seen the *:::no-loc text="eShopOnContainers":::* app's existing checkout process. You'll review the design of the new coupon service in the next unit.
