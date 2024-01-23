# uaictl

The uaictl package provides a system administration CLI for managing User
Access Instances (UAIs) on HPE Cray systems. This CLI must be run as root.

UAIs are implemented as rootless podman containers running as the user.
There is no central graphroot of UAI data. Each UAI host contains a 
graphroot of the UAIs on that host. This implementation provides for 
security and isolation between UAIs.

The uaictl provides for managing UAIs across multiple host servers. It also
works around an issue in how podman works which renders UAIs unmanageable by
the original owner when queried by any other owner.

When podman queries container status, it updates an overlay/l file and changes
the ownership of that layer to the user making the query. This change in
ownership prevents the original user from being able to access or manaage
their own UAIs. The uaictl CLI works around this by making the queries as 
the actual user.

