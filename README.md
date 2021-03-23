# copy_certs_to_udmpro
Copy existing SSL certificates to Ubiquity UDM-PRO for both admin access and the hotspot portal page

The intention of this script is to facilitate the installation of existing certificates into a UDM-PRO device.

I already have letsencrypt running centrally and just needed a way to get the certs into the UDM-PRO.

Prerequisites:

1. You'll need openssl installed.

2. You'll need keytool which is part of JRE/JDK.

3. It's assumed that you have ssh access to your UDM-PRO. To get that you need to install your ssh key. Once that's installed you have access as root without a password.

Disclaimer: As the UDM-PRO code is a moving target, I make no representation as to the completeness or correctness of any of this. Use at your own risk.

Hope you find it useful!
