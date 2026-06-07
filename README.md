# unifi-network-Server
k8s deployment of Ubiquiti 's UniFi Network Server

**Note: Make sure your CPU supports AVX2 instructions or this wont work (if running k8s work in proxmox set VM's CPU to `host` so compatible instruction sets get passed into the worker VM. (Ask me how I know)**

Im going to preface this readme with a short note. I get this isn't how you should deploy something to a k8s cluster but I was lazy and didn't really feel like building a pipeline to generate an image and then scheduling that pipeline to patch and generate new images once a month. Instead I just restart my pod to patch unifi server. Yes this is jank but it works and was created more for fun than anything. with that said.


## How I set this up and how it all works



Each of my K8s nodes have an NFS mount back to my storage(`/opt/persistent_volumes/unifi` in this case)
I mount my unifi config/database to this shared storage so when I restart my pod my data is still there.

I only deploy 1 instance at a time since unifi manages the MongoDB data and puts a lock on the database, but unifi does not really need to be HA since configs are stored on the devices it manages. So it can be down for 2-3 minutes while a new pod is spun up.


Next problem to solve was device discovery.

Since unifi likes to just use udp packets on the same subnet to discover devices this would not work correctly since the pod network is different then my device subnet. I made things much harder here by wanting to use isto ingress for my webgui. I could of just put everything into the loadballancer config and been done with it but I wanted signed certs for the webgui in a codified way. 

To get device discovery working I added an option to my dhcp server to hand out the loadballancer's IP.
I use OPNSence and Kea DHCP. Add option 43, Encoded as `hex` and the set data is just the hex value of the LB IP `0104C0A800CB`(192.168.0.203) in this case. You can then add this option to the whole subnet or if you are like me and add dhcp reservations up for network devices like these, you can add the option to each reservation.

If done correctly your Unifi controller should now be running in K8s and will migrate between workers as it needs to. Offers more flexibility then a static vm.


## Conclusion
At the time of doing this project Ubiquiti is really pushing people to Unifi OS. Unifi OS is a standalone installer that installs podman that then runs unifi controller with in containers there. On paper this is really cool because they are finally doing containerization. But the reason I find it frustrating is they are using a private container registry to store their images and not a registry you can just use(requires an auth token baked into their installer that you cant access). I just want to call them in my deployment.yml and then just mount my own storage ::pleading:: Maybe Ubiquiti will just publish their images to google or docker hub someday ::shrug::
For now I will just jankily build my own Unifi OS I can use in k8s
