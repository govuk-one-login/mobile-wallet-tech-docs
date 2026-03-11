# GOV.UK Wallet technical documentation
This documentation is for government services that want to integrate with GOV.UK Wallet.


The Wallet technical documentation is based on the [Tech Docs Template](https://github.com/alphagov/tech-docs-template) - a [Middleman template](https://github.com/alphagov/tech-docs-template#:~:text=Template%20is%20a-,Middleman%20template,-that%20you%20can) to build technical documentation using a GOV.UK style.

## Preview the documentation in a browser

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

You can preview the site using a local version of the `tech-docs-gem` by adding the `true` argument to the command.

```bash
./preview-with-docker.sh true
```

The preview script will expect your local gem repository to be in the same parent directory as these tech-docs, for example:

```
my-computer/projects/
            ├── tech-docs-repo/ 
                |── source /
            ├── tech-docs-gem-repo/ # on the branch you're testing

```

## Making changes to content

To add or change content, edit the markdown in the `.html.md.erb` files in the `source` folder.

In order to configure some aspects of layout, like the header, edit `config/tech-docs.yml`.

If you move pages around and URLs change, make sure you set up redirects from the old URLs to the new URLs.

## Content structure

This documentation is split into 3 main sections:

- introduction and overview
- information for verifiers
- information for issuers

These are managed by the `header_links` section of the `config/tech-docs.yml` file, and custom layouts for the Table of Contents (ToC).  Including the `/` at the end the header link path helps `middleman` to open the ToC at the right section.

Your links will now appear in the navigation bar, and take users to the page you defined above. The config above would look like this:

### Custom layouts

This documentation uses custom layouts to generate the ToC for each of the main sections outlined above.  The following layouts are in the `source/layouts` directory:

- `main.erb` - for introduction and overview pages
- `issuer.erb` - for pages about issuing credentials
- `verifier.erb` - for pages about verifying credentials

Layouts are applied to a page by including them in the `frontmatter` code block, for example:

```diff
    ---
    title: GOV.UK Wallet Technical Documentation
    weight: 1
    last_reviewed_on: 2025-11-27
    review_in: 6 months
+   layout: main 
    ---
```

#### Update main layout

The `main` layout contains pages in the root directory.  We do not want to include every page in the ToC (for example the accessibility statement).  To add a page to the ToC add a new `page_resource` to the `render_page_tree` function. 

```diff
<% contact_us_page = sitemap.resources.find {|resource| resource.path == "contact-us.html" } %>
+ <% your_new_page = sitemap.resources.find {|resource| resource.path == "new-page.html" } %>
...
- <%= render_page_tree [documentation_page,contact_us_page], current_page, config, yield %>
+ <%= render_page_tree [documentation_page,contact_us_page, your_new_page], current_page, config, yield %>
```

#### Update issuer or verifier layout

The `verifier` and `issuer` layouts create their ToC based on the directory structure.  The `verifier` layout finds all the pages that are `children` of `source/verify-credentials`, for example `source/verify-credentials/verification-flows/index.html.md.erb`.   

The layouts also include the parent folder (`source/verify-credentials`) in the ToC by passing the optional `include_child_resources: false` parameter.  More information is available about [helper functions in the `tech-docs-gem`](https://github.com/alphagov/tech-docs-gem?tab=readme-ov-file#table-of-contents-helper-functions)

## Checking links with HTML Proofer

You can use the [html-proofer gem](https://github.com/gjtorikian/html-proofer/tree/main?tab=readme-ov-file#htmlproofer) to check that internal and external links in your site are valid. The settings for this gem are managed in `./run_html_proofer.rb`.

The gem checks the built site and confirms that links point to valid files or anchor tags. Run it locally before committing:

```bash
bundle install && bundle exec "ruby run_html_proofer.rb"
```

### Running checks with Rake commands

This project has a `Rakefile` to run useful commands.  You can use this to create a clean middleman build on your local machine by running the following commands in your terminal:

```bash
rake clean_middleman_build 
```
You can also use `rake` to run the `html-proofer`

```bash
rake run_html_proofer 
```

## Code of conduct

Please refer to the `alphagov` [code of conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md).

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE.md
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
