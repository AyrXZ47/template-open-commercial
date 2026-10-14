## AI tooling

This repository is worked with **Pi + Gentle-AI** (ODD for everyday work, RDD for review). Agent skills are installed globally in Pi from upstream, never vendored here:

    pi install git:github.com/cloudflare/security-audit-skill
    pi install git:github.com/DietrichGebert/ponytail

Commit convention: conventional commits, one imperative line under ~72 chars, one logical change per commit, no AI attribution.

## 📜 Project Licenses

This repository uses a multi-license model to protect different types of assets:

* **Source Code (`/src`, `/scripts`):** Licensed under **Apache 2.0** - See [`LICENSE-SOFTWARE`](LICENSE-SOFTWARE).
* **Hardware Designs (`/hardware`, `/kicad`):** Licensed under **CERN-OHL-P v2** - See [`LICENSE-HARDWARE`](LICENSE-HARDWARE).
* **Documentation & Media (`/docs`, LaTeX, Renders):** Licensed under **CC BY 4.0** - See [`LICENSE-MEDIA`](LICENSE-MEDIA).
