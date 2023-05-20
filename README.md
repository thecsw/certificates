# certificates

Make your own custom certificate authority and signed server/client certificates
with ease!

## Config

Every certificate will be generated according to OpenSSL configuration files that
are defined in [configs](./configs). Some strong default encryption algorithms and 
encodings have been set, which are compatible with newer and older software (at the
very least, it is TLSv1.3)

Take a look around those configuration files, as they are pretty much self-explanatory.
(my great last words, heh)

## Your CA

If you are familiar with how [certificate authorities](https://en.wikipedia.org/wiki/Certificate_authority)
operate, you need to first get yourself a **super duper** secure and **trusted** certificate,
which you will use to verify your servers and (hopefully) clients. There are many pre-installed
root CAs in your system, this repo will help you make your own. (you can import it later into 
your system's list of trusted CAs)

For that very reason, for root CA, you don't really need much in terms of filling out domains
or anything like that. Mostly give the certificate a nice `commonName` (CN), where everything else
in the section is optional.

So then to generate your CA, run the following command,

```sh
λ ./gen_ca.sh
```

which will create a directory with the following files:

- `ca.crt` - your CA's PEM (a base64 version) certificate, do share it in your services for verification and trust.
- `ca.csr` - your CA's certificate signing request to the CA (self-signed), feel free to discard.
- `ca.der` - your CA's DER (binary output) certificate, do share it in your services just like the PEM version.
- `ca.key` - your CA's private RSA 4096 bit (default) key. **DO NOT EVER SHARE AND KEEP SECRET**
- `ca.pem` - your CA's private key but PEM encoded (a different encoding). **DO NOT EVER SHARE AND KEEP SECRET**

Keep the `.key` and `.pem` secret in all situations (only used for signing) and use `.crt` and `.der` in your
programs and services.

### What about chaining CAs?

Unless you are a big corp or in dire need of using intermediate and leaf certificates to verify the chain
of trust, you can figure out how to do that on your own. This repo is for situations where you need a central
CA and services/users signed by that CA.

TODO: Maybe someone wants to add additional scripts? The process is the same though, make another CA, sign it
with the root CA, and then sign other services with the former. Not hard.

## Server Certificates

Say you have a redis service that you want to use a TLS/SSL handshake (actually, TLS, but we still call it SSL
for legacy reasons). Imagine my redis server is `redis.sandyuraz.com`.

In addition to my root CA, I would need to create a certificate with `commonName` set to `redis.sandyuraz.com`
or have one of the subject alternative names (SAN) (see `DNS.N = ...`, where `N` is an integer in
[server config](./configs/server.txt))

Whenever a user comes in and initiates a [TLS handshake](https://www.cloudflare.com/learning/ssl/what-happens-in-a-tls-handshake/)
with your server, the user gets the server's certificate and a commonly trusted CA, verifies that the trusted CA
signed server's certificate (CA's private key is needed) and the server that the client is talking to the actual
owner (through CN or SAN), session key gets generated, yadda yadda.

Boom, you got yourself a trusted connection with the server. Well, of course, if CA is compromised, say its 
private key got out--you're out of luck.

To generate server certificates, make sure you have run CA generation above and have `ca` directory. Then, run

```sh
λ ./gen_crt.sh server
```

All the output would be the same as above in `./server` directory, except that it will use an 
[EC](https://blog.cloudflare.com/a-relatively-easy-to-understand-primer-on-elliptic-curve-cryptography/)
private key (very cheap and secure), and it will have the server certificate's serial (`./server/server.srl`)

You can see what
[serials and thumbprints are](https://security.stackexchange.com/questions/35691/what-is-the-difference-between-serial-number-and-thumbprint).

## Client Certificates

I also like to have my clients verified as well. So, not only does the server have to prove to clients that they
are who they say they are, but clients have to prove that they have also been vetted by their trusted CA.

Of course, client's can't really prove its domain all the time (think of you as a developer remoting in),
so I tend to leave the `SAN` out of it (you can easily modify the config to have that added as well).

The process is going to be exactly the same as above but with

```sh
λ ./gen_crt.sh client
```

as the command and generated keys/certificates/extra will be found in the `./client` directory.

Goodbye!
