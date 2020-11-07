---
title: Avoiding Rails folder inflation
published: false
---

After working on a dozen of Rails projects for some months, disk space became pretty tight.
It took me a dumbfounded second to realize I had no procedure in place to contain temporary files.

The culprits were Rails logs and Webpacker builds, easily summing up to a couple of Gb per project.

The immediate problem can be fixed by by two Rake tasks:

```bash
rake log:clear webpacker:clobber
```

