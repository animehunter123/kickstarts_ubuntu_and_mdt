# Description
These scripts will download pypi using the rocky9 config generated from the docs already in the results_02

After it is done you can confirm that your new destination webserver that will host pypi works with a quick test:
```bash
  pip uninstall -y numpy pandas dash ; pip cache purge

  pip install  --find-links=http://172.16.0.63/ numpy pandas dash  --trusted-host 172.16.0.63
```

# Usage (Quickstart)

```@@@ 
IMPORTANT NOTE: 

You need to run these scripts on the target os so that it fetches that specific environment of pypi. 

Be sure to note down what os/arch packages as you build your repo folder so that you know what is downloaded.

I.e. if you used Rocky93 VM it will get a pypi_rocky93, elsea Windows10 with Python12.2 to get pypi_win10_py122, for example.

@@@```

* FIRST, Make a HOST FRESH VM using the TARGET OS/ARCHITECTURE/REQUIRED_PYTHON_VERSION (i.e. 8C/32GBRAM with Rocky9.3 Python3.9.18)

* NEXT, the nas destination directory via /etc/fstab: ```172.16.0.5:/volume1/MYSITENAS-Data /mnt/MYSITENAS-Data nfs defaults 0 0```

* THEN, Copy the shell scripts, and look over them, currently I set them to DOWNLOAD INTO: ```TARGET="/mnt/MYSITENAS-Data/repos/pypi-pipdownloaded" # make sure you mounted it on your host```

* Launch/Read the scripts carefully in order (RUN IT AS ROOT)... basically...:

* ./1*.sh  # this makes a result01 file (index.html of full pypi.org)
* ./2*.txt # MAKE A CRONJOB to CLEAN UP THE .cache/pip folder...BEFORE DOWNLOADING PACKAGES
* ./3*.sh  # this makes a result02 packagenames (parsed from index.html of full pypi.org)
* ./4*.py  # nohup ./4*.sh & # This starts the full download. 
  Check ```tail -f nohup.out``` to see package download progress
  Check ```nethogs``` to see byte performance, 
  Check ```du -sh ./pypi-mirror``` to see mirrored folder size slowly increase.
* ./5*.txt # this creates a ./simple (with symlinks and index.htmls containing sha256)
* ./6.txt  # this shows how to set up Nginx Config files

# The secret of why this works... PEP 503 Prompt and the secret of the HTML files which allow "pip install" to work!

Basically, we make a folder and host it on a web server.

Why does this work?

Well.. To create a PEP 503 simple repository API structure from a directory containing .tgz and .whl files, you need to follow these specific steps:

1. Create the base directory structure:

```
/your_repository_root/
    simple/
        index.html
```

2. Create subdirectories for each package:
For each unique package name in your .tgz/.whl files, create a subdirectory under `simple/`. The name should be normalized: lowercase, and replace any runs of `-`, `_`, or `.` with a single `-`.

Example:
```
/your_repository_root/
    simple/
        package-name/
        another-package/
```

3. Create index.html files:

a. In the root `simple/` directory, create an `index.html` file listing all packages:

```html
<!DOCTYPE html>
<html>
  <body>
    <a href="package-name/">package-name</a>
    <a href="another-package/">another-package</a>
  </body>
</html>
```

b. In each package subdirectory, create an `index.html` file listing all versions of that package:

```html
<!DOCTYPE html>
<html>
  <body>
    <a href="../../package-name-1.0.0.tar.gz#sha256=abc123">package-name-1.0.0.tar.gz</a>
    <a href="../../package-name-1.0.0-py3-none-any.whl#sha256=def456">package-name-1.0.0-py3-none-any.whl</a>
  </body>
</html>
```

Key points for the package-specific index.html files:

- The `href` attribute should be a relative path to the actual file.
- Include a hash (preferably SHA256) as a URL fragment.
- The link text should exactly match the filename.

4. Move or symlink your .tgz and .whl files:
Place all your package files in the repository root, or create symlinks to their current location.

Final structure:
```
/your_repository_root/
    simple/
        index.html
        package-name/
            index.html
        another-package/
            index.html
    package-name-1.0.0.tar.gz
    package-name-1.0.0-py3-none-any.whl
    another-package-2.1.0.tar.gz
```

5. Ensure correct MIME types:
Configure your web server to serve:
- .html files as `text/html`
- .whl files as `application/octet-stream`
- .tar.gz files as `application/x-gzip`

6. Enable directory listings (optional):
While not required by PEP 503, enabling directory listings can be helpful. In Apache, you can do this with:

```
Options +Indexes
```

7. Ensure all URLs end with a trailing slash:
Configure your web server to add a trailing slash to directory URLs if missing.

THUSSSSSSSSSSSSS WE NOW HAVE A a PEP 503 compliant simple repository API structure. This structure allows pip and other package managers to correctly index and install packages from your repository! Pretty awesome!
