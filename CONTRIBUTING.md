# Factorio pollution simulation

## Contents

-  [Contributor Requirements](#contributor-requirements)
   -  [Developer Certiticate of Origin](#developer-certiticate-of-origin)
   -  [GPG-Signed Commits](#gpg-signed-commits)
   -  [OpenPGP Public Key](#openpgp-public-key)
-  [Code of Conduct](#code-of-conduct)
-  [Issues and Bugs](#issues-and-bugs)
   -  [Find One, Report One](#find-one-report-one)
   -  [Find One, Patch One](#find-one-patch-one)
-  [Feature Requests and Enhancements](#feature-requests-and-enhancements)
-  [Using the Project Locally](#using-the-project-locally)

---

## Contributor Requirements

### Developer Certiticate of Origin

This project uses the Developer Certificate of Origin, Version 1.1 used by Linux Foundation in developing the Linux Kernel. The Developer Certificate of Origin is in the root of this repository as [`DCO.md`](./DCO.md), and online at [http://developercertificate.org/](http://developercertificate.org/). In short, it says that you know where your contribution came from, you know you have the right to distribute it under the same license as this project, and that you can, and do, grant the right for this project to distribute it under the license used for this project, found in the root of this repository as [`LICENSE.md`](./LICENSE.md). You, as a contributor, signify that you agree to the _Developer Certificate of Origin_ by inluding a sign-off line, "Signed-off-by", with any commit you make. You may type this line on your own when writing your commit messages. However, the `git` command makes doing this simple, use the `--signoff` or `-s` option when you make your commit. Inside the commit message it will look like this:

    Signed-off-by: Your GitConfigName <username@domain.tld>

Pseudonymous or anonymous contributions are permissible, but you must be reachable at the email provided in the "Signed-off-by" line, not just through your account on GitLab, GitHub, etc.

### GPG-Signed Commits

In addition, to be acceptable to this project, the commits must be GPG-signed in a manner verifiable by the site(s) on which the commit is posted. Again, the git command makes this simple with the "--gpg-sign[=<keyid>]" or "-S[<keyid>]" options for a commit. This, of course, means that you will need to have a PGP key for the same email address as you use for creating the commits. GitLab has a good page, [Signing commits with GPG](https://gitlab.com/help/user/project/repository/gpg_signed_commits/index.md), which explains, and guides you through the process of creating one, and GitHub has a good page, [Generating a new GPG key](https://help.github.com/articles/generating-a-new-gpg-key/), for essentially the same process. Both also help you associate the new PGP key with your account on their server, if you wish.

I would recommend that where the instructions suggest selecting the default of `RSA and RSA` that you select `ECC and ECC` instead. The size of the keys are shorter and the time and work you computer uses to generate and use the keys is less. Selecting the ECC option causes the selection of key size to be replaced with a selection of which elliptic curve to use, in which case I recommend the `Curve 25519` option. The choice of which option to use is a personal choice, and either way is acceptable here, as long as the commits are signed with a valid PGP key.

### OpenPGP Public Key

One extra step that is required beyond the GitLab or GitHub help example is that your key must also be on a public key server somewhere which is accessable to myself, and anyone else who wishes to verify signatures from this repo. Two choices, that I know of, are the regular public key server network and [Keybase](https://keybase.io/). The public key server pool can be accessed directly by [GNU Privacy Guard](https://www.gnupg.org/), the `gpg` command line tool, or on the web at many addresses, including a host at MIT, [https://pgp.mit.edu](https://pgp.mit.edu/). The [Keybase app](https://keybase.io/download) supposedly makes things easier to use, and increases other users confidence in the connection between an identity and the key. However it is done, I support and encourage the personal and professional use of encryption in every possible case. Requiring contributors here to have, and use, an OpenPGP key is just one way to advance the cause.

[TOP](#contents)

---

## Code of Conduct

Please read the [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) file in this repo for our Code of Conduct.

[TOP](#contents)

---

## Issues and Bugs

### Find One, Report One

If you find a bug, or have an issue with how something works, or doesn't work, open an [Issue](../../issues) on the project page. Typos also qualify as an issue.

Maybe it is not a bug, or is the result of a prior decision, maybe it is a problem and needs to be fixed. Either way, the [Issue](../../issues) will be seen and handled.bbb

### Find One, Patch One

If you find a truly serious bug, and know how to fix it, code the solution and create a Merge request, or a Pull request as the case may be, in this repo.

Kudos to anyone willing to take the time to create solutions rather than notices. Please read the [__Contributor requirements__](#contributor-requirements) section above.

[TOP](#contents)

---

## Feature Requests and Enhancements

Treat these like an issue you found. This project is small enough that there probably are not any meaningful enhancements possible that are not already planned without taking it out of its planned scope. Asking, or offering, won't hurt anything however, and suggestions are always welcome. So create and submit an [Issue](../../issues) anyway. ([See above](#issues-and-bugs).)

[TOP](#contents)

---

## Using the project locally

At any stage you find this project in feel free to copy and use what you find within the scope of the [license](./LICENSE.md) applied to this project.

[TOP](#contents)

---
