# Appwrite Configuration

We use Appwrite as a back-end for our application.
This directory stores the project configuration which can be used to quickly deploy the required settings.


# Setting up Appwrite

## Server

Before initializing the project, you need to set up a server. You have two options for this:
- Use Appwrite Cloud;
- Self-host a server.

Appwrite Cloud is the easiest way to get started, but **the free plan is NOT sufficient!**
When decididing to self-host, you can use the following tutorial: https://appwrite.io/docs/advanced/self-hosting
The exact setup instructions heavily depend on your exact use case, and explaining this is out of scope
for this document.

After choosing a server, go ahead and create an account. Do NOT create a project yet, we will do this later.

## CLI

We will use the command-line interface to deploy our configuration.
Install it from here: https://appwrite.io/docs/tooling/command-line/installation

# Setting up the project

## Logging in

Let's first authenticate using the CLI:

```bash
$ appwrite login
```

Enter your details as created above.
When using Appwrite Cloud, use `https://cloud.appwrite.io/v1` as the server URL.

## Creating a project

This does NOT work (why not??)
TODO: fix

```bash
$ appwrite projects create --projectId tcs-design-project-mindfulstudent --name MindfulStudent
```

## Deploying resources

```bash
$ appwrite deploy collection
  < press A, then enter >

$ appwrite deploy function
  < press A, then enter >
```

## Authorizing Functions

We need to create an API key which will authorize our custom functions to run.
In the dashboard, go to your project, then Overview -> API Keys -> Create API Key.
Call it `Appwrite Functions`, set the expiration date to `Never` and continue.
On the "Add Scopes" screen, select all scopes and click `Create`. Copy the API key secret.

Now again, go to your project and click "Settings." Under Global Variables, create a new variable.
Call it `APPWRITE_FUNCTION_API_KEY` and set its value to the key you just copied.
Save it and done!
