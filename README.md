# GOV.UK Wallet technical documentation
This documentation is for government services that want to integrate with GOV.UK Wallet.


The Wallet technical documentation is based on the [Tech Docs Template](https://github.com/alphagov/tech-docs-template) - a [Middleman template](https://github.com/alphagov/tech-docs-template#:~:text=Template%20is%20a-,Middleman%20template,-that%20you%20can) to build technical documentation using a GOV.UK style.

# Preview the documentation in a browser

To preview any changes and additions you have made to the documentation in a browser, clone this repo and use the [Dockerfile in this repo](Dockerfile) to run a Middleman server on your machine without having to set up Ruby locally.

This setup has live reload enabled, which means your changes will be applied as you edit files in the source directory. The only exception to this is if you make changes to `config/tech-docs.yml`, you must stop and restart the server to see your changes in the preview. You can stop the server with `Ctrl-C`.

Run the [helper script](preview-with-docker.sh):

```bash
./preview-with-docker.sh
```

It may take a few minutes to build the docker container, particularly if it is your first time running the script. When the server has finished loading you should then see the following output in the terminal:

```bash
== View your site at "http://localhost:4567", "http://127.0.0.1:4567"
```

## Making changes to content

To add or change content, edit the markdown in the `.html.md.erb` files in the `source` folder.

If you do not want the `index.html.md.rb` to be included in the [table of contents (ToC)](#table-of-contents) you can hide it from navigation by adding the following to the top of the page:

```diff
---
title: Issuing credentials to GOV.UK Wallet
weight: 1
last_reviewed_on: 2025-11-27
review_in: 6 months
+ hide_in_navigation: true
---
```


If you move pages around and URLs change, make sure you set up redirects from the old URLs to the new URLs.

## Code of conduct

Please refer to the `alphagov` [code of conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md).

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE.md
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
