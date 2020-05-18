# CVP Audio Ingress
## Deploys the CVP audio only ingress platform

This project is a tactical solution to provide audio recordings for online hearings. The project has been expedited due
to the Covid-19 outbreak and as such the design and implementation is subject to change in the future.

The main solution consists of 2 active-active loadbalanced Linux VMs running Wowza Streaming Engine 4.7.7 which then 
store the audio output in Azure Blob Storage. 

## Environments

The project can be deployed to the following 3 environments:

* Shared Services Sandbox - Used for dev work
* Shared Services Staging - Used as a pre-prod type environment and for end-to-end/load testing
* Shared Services Production

## Testing
The following command streams a single
```shell script
ffmpeg -re -i ./<local audio file> -c copy -f flv "rtmps://<host name for your wowza engine instance or the lb>:443/audiostream5 flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza playpath=<target filename>"
``` 

Load testing can be conducted on a Windows VM on Azure (Standard DS11 v2). It will require dotnet core installing on it.
Once installed you can download, build and run from this project: 
[https://github.com/hmcts/vh-performance-wowza](https://github.com/hmcts/vh-performance-wowza)



## Known issues
* The Wowza Engine Management UI doesn't seem to work when the Wowza Engine is configured with TLS (which this project 
is).
