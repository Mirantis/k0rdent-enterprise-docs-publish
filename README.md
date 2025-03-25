# Mirantis k0rdent Enterprise Documentation

This project utilises Mkdocs with the Material theme and Mermaid for
diagrams. Currently the docs are published using github actions on github pages
from the branch gh-pages, which contains static site files generated from
Markdown documents and assets. The overall configuration of the site is
stored in mkdocs.yml in the root directory of the repo. If making contributions
to docs, it can be useful to host it locally to see the effect of changes.

## Project layout (root directory)

    mkdocs.yml                # The configuration file
    requirements.txt          # mkdocs requirements file for pip, used to locally install mkdocs and its plugins (normally in a Python venv)
    dockerfile                # Docker manifest for locally serving the site through a container (alternative to locally installing mkdocs)
    docs/                     # Documentation files in Markdown (.md), subfolders for /img, /assets, /stylesheets, /css, etc.

## Setting up MKdocs locally (Linux)

1. Clone repo and cd to its root:

    ```bash
    git clone https://github.com/mirantis-docs/k0rdent-enterprise-docs.git
    cd k0rdent-enterprise-docs
    ```
    
2. Setup a Python venv and activate it

    ```bash
    python3 -m venv ./mkdocs
    source ./mkdocs/bin/activate
    ```

3. Install MkDocs and dependencies from requirements.txt

    ```bash
    pip install -r requirements.txt
    ```

4. Create a feature branch, copying main (next docs) or a version branch (e.g., release-v0.1.0) you want to update

    ```bash
    git checkout main                     # or release-v0.1.0 etc. - check out the branch you want to update
    git pull origin main                  # or release-v0.1.0 etc. - update from origin
    git checkout -b my-feature-branch     # copy the original branch into your feature branch
    (make changes)
    git push -u origin my-feature-branch  # push to origin and file Pull Request
    ```
      
5. Serve site to 127.0.0.1:8000 (server is live-reloading, so see effects of changes immediately)

    ```bash
    git checkout my-feature-branch        # check out your feature branch
    mkdocs serve                          # serve docs from that feature branch
    ```

## Use containerized mkdocs instead (assumes you have Docker installed locally)

1. Build the container from the provided Dockerfile

    ```bash
    docker build -f Dockerfile -t mk-local
    ```

2. Clone repo as in Step 1, above, and cd to repo root

3. Create and checkout your working branch, as in steps 4 and 5, above.

4. Open a new terminal session (so you can stop the container later by pressing CTRL-C) and run the container

    ```bash
    docker run --rm -it -p 8000:8000 -v ${PWD}:/docs mk-local
    ```

# Documentation Standards

By default, we follow the [Kubernetes documentation style guide](https://kubernetes.io/docs/contribute/style/style-guide/). 

## Header Capitalization

All header text should be capitalized.

## Referencing Kubernetes nested resources

Please use the dot notation.  So in the following:

```
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
```

To refer to the `name` field, please use `.metadata.name` and not `name`.
