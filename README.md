# [] technical documentation
Where the documentation of the [] is located.

The [] technical documentation is based on the [Tech Docs Template](https://github.com/alphagov/tech-docs-template) - a [Middleman template](https://github.com/alphagov/tech-docs-template#:~:text=Template%20is%20a-,Middleman%20template,-that%20you%20can) to build technical documentation using a GOV.UK style.

# Getting Started
Middleman uses Ruby to generate static web pages from Markdown files, so you'll need Ruby installed.

## Install Ruby

Start by installing [rbenv](https://github.com/rbenv/rbenv) and [ruby-build](https://github.com/rbenv/ruby-build):
```
brew upgrade rbenv ruby-build
```
This will allow you to compile Ruby, and makes it easier to manage multiple Ruby environments (macOS comes with Ruby installed, so this simplifies things).

Download the current version of Ruby that the [application uses](.ruby-version):
```
rbenv install
```

Install the application's dependencies:

```
bundle install
```

### Fix `ffi` bug on MacOS

There's an incompatibility issue with the latest MacOS and the `ffi` library which stops Middleman from starting on MacOS.

To fix the issue you must stop the `ffi` gem using the native `libffi` library by sending this command:

```shell script
bundle config build.ffi --disable-system-libffi
bundle install # reinstall
```

## Making changes in the documentation
To make changes, edit the Markdown files in the source folder.

Although a single page of HTML is generated, the markdown is spread across multiple files to make it easier to manage. They can be found in `source/`.

Images to be included in the docs are kept in `source/images`

In order to configure some aspects of layout, like the header, edit `config/tech-docs.yml`.

### Build the documentation

Once happy with your changes, you'll need to (re-)build the static website.

```
bundle exec middleman build
```

### Preview in the browser

Whilst writing documentation, you can run a middleman server to preview how the documentation will look in the browser.

The preview is only available on your own computer. Others will not be able to access it if you give them the link.

Type one of the following to start the server:

* `bundle exec middleman server` - if you have ruby installed locally
* `./preview-with-docker.sh` - if you have Docker installed

If all goes well, something like the following output will be displayed:

```
== The Middleman is loading
== LiveReload accepting connections from ws://192.168.0.8:35729
== View your site at "http://Laptop.local:4567", "http://192.168.0.8:4567"
== Inspect your site configuration at "http://Laptop.local:4567/__middleman", "http://192.168.0.8:4567/__middleman"
You should now be able to view a live preview at http://localhost:4567.
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
