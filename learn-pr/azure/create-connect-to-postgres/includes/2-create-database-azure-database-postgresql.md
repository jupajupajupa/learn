An Azure Database for PostgreSQL instance can be created using the Azure portal, Cloud Shell, or CLI.  

**Azure portal** is a web-based, graphical user interface that provides an alternative to command-line tools. With the Azure portal, you can build, manage, and monitor everything from simple web apps to complex cloud deployments.

**Azure Cloud Shell** is an interactive shell environment that’s accessible through your browser. Bash and PowerShell function with Cloud Shell, which has pre-installed commands for creating and configuring Azure Database for PostgreSQL instances. This means there’s no need to install anything on your local environment.

**Azure CLI** can be installed locally, giving you the same functionality as the Azure Cloud Shell.

## Pricing tiers, explained

The Single Server deployment option of Azure Database for PostgreSQL has three different pricing tiers. Each tier provides different levels of performance for compute and storage. You can scale performance up or down, and change tiers, as needed.

**Basic tier** is suited for workloads that require light compute and storage performance. This could include servers used for development or small-scale applications.

**General Purpose** is ideal for most business workloads. It offers balanced compute and storage performance, and is ideal for servers hosting web and mobile apps.

**Memory Optimized** is specifically for high-performance applications on a single server. This option caters to database workloads that need support for many simultaneous transactions and fast transaction processing. This could include servers that process real-time data, and high-performance transactional or analytical apps.

Full compute and storage details for the different pricing tiers are available in Unit 9 - Summary.

For our payment app scenario, the Basic tier is suitable while the app undergoes development. For a trial, either the General Purpose or Memory Optimized tiers would be suitable.
## Scale up compute or storage needs

You can adjust your compute (vCore) and storage needs at any time through the Azure portal or Azure CLI.

After you’ve created a server, you can scale between the various pricing tiers as your needs change. You can also scale up or down your compute and memory by increasing or decreasing vCores.

When our payment app is in trial, it's a good idea to scale up compute ahead of time. During the trial, we can look at the compute usage and scale down the number of vCores to an appropriate level.

## Back up your data

Protecting your data from accidental corruption or deletion is an essential, yet time consuming, part of development. Azure automatically creates server backups, but offers flexibility for different requirements.

**Backups can restore data to any point in time within the last 35 days**, and are retained in backup storage. You can select a retention period of 7 to 35 days in the Azure portal.

Azure Database for PostgreSQL automatically provides up to 100% of your provisioned server storage as backup storage, at no additional cost. For example, if you provision a server with 250 GB of storage, you’ll have 250 GB of additional storage available for server backups, at no extra charge.

During payment app database deployment, we'll set a 35-day retention period. We don’t have to worry about running out of storage with the **auto-grow** feature enabled - Azure will automatically increase the size of the storage, if needed.

### Geo vs Local: Backup redundancy options

Azure Database for PostgreSQL provides the flexibility to choose either locally redundant or geo-redundant backup storage.

**Locally redundant backups** are stored within the region in which your server is hosted. The Basic pricing tier only offers locally redundant backup storage.

**Geo-redundant backups** are stored in a separate data center in a geo-paired region. This provides better protection and allows you to restore your server from a different region if there is a disaster.

> [!IMPORTANT]
> Choosing between local or geo-redundant storage for backup is only permitted during the creation of the server. After the server has been provisioned, the backup storage redundancy option cannot be changed.
