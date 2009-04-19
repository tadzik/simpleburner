### DESCRIPTION:

Simpleburn is program running under the CLI environment to make Your burning CD/DVD’s easier.

### HOMEPAGE:

<http://wiki.github.com/sirmacik/simpleburner>

### DEPENDENCES:

* perl(>=5.10.0) - <http://www.perl.org>
* cdrkit - <http://www.cdrkit.org/>

### INSTALLATION:

To get the source of simpleburnerer run:

`$ git clone git://github.com/sirmacik/simpleburnerer.git`

And then install with command:

`# install -Dm simpleburnerer/simpleburnerer.pl /usr/bin/simpleburnerer`

You could also install it with PKGBUILD <http://aur.archlinux.org/packages.php?ID=25672> from AUR

### WARNING:

To burn Your CD You must put Your files into default /tmp/burner directory or run burner with —data=/your/burndata/directory option

### WARNING:

If You create iso image, by default  You'll find it in /tmp directory but You could set Your own location

### OPTIONS:
    * h|help         - print help message
    * test           - run in test burn mode
    * b|burn-only    - run without making iso image (‘—name=/full/path/to/image.iso’iso option must be defined)
    * m|makeiso      - make only iso image (without burn), by default Your iso file will be stored in /tmp
    * data=s         - set directory willth data to burn (default /tmp/burner)
    * name=s         - set name of iso file (defaultault cd.iso)
    * burner=s       - set burner to use (default /dev/sr0)
