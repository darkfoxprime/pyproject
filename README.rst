A minimal python project release system.
Not for other people to use yet.

assumes presence of a `.pyproject` file in the root of the python project.
minimal contents:

::

    [project]
    name=...
    version=...
    docfile=...

    [github]
    user=...
    repo=...

The following settings are defined in the `project` block:

* `name` is the name of the project
* `version` is the Semantic Versioning version number of the project
* `docfile` is the file which will be updated with new information for new releases.

  * this is very specific to my format, and needs to be generalized.

The following settings are defined in the `github` block:

* `user` and `repo` define the github repository which hosts the project.

  *  For example, http://github.com/foo/bar would have `user` set to `foo` and `repo` set to `bar`.

----

There are currently three tools:

* `bump`

  * bumps the version number of the project, using the semantics of the Semantic Versioning specification.
  * Allows the use of pre-release tags (-foo) and build metadata (+foo).

* `prepare`

  * takes the information in the `.pyproject` file, plus github change log information;
     uses that to update the main documentation file (`docfile`) and the CHANGELOG.rst file.

  * requires both the `github_changelog_generator` ruby gem and the `pandoc` package.

* `release`

  * Generates distribution files and `releases` them to hosting sites (currently, github and pypi).
  * github requires one additional setting in the `github` block:

    * `token` holds a Personal Access Token which must be created in the GitHub account settings with "public repo" permissions.

  * pypi requires that `twine` be installed and configured.

----

Ironically, for a tool to manage python project releases, this is written entirely in bash scripts. :P
