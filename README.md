### DESCRIPTION:

Simpleburn is program running under the CLI environment to make Your burning CD/DVD’s easier.

### INSTALLATION:

To get the source of simpleburnerer run:

`$ git clone git://github.com/sirmacik/simpleburnerer.git`

And then install with command:

`# install -Dm simpleburnerer/simpleburnerer.pl /usr/bin/simpleburnerer`

You could also install it with PKGBUILD <http://aur.archlinux.org/packages.php?ID=25670> from AUR

### WARNING:

To burn Your CD You must put Your files into default /tmp/burner directory or run burner
with—data=/your/burndata/directory option

### WARNING:

If You create iso image You will find it in /tmp directory

### OPTIONS:
    * h|help         - print help message
    * test           - run in test burn mode
    * b|burn-only    - run without making iso image (‘—name=/full/path/to/image.iso’iso option must be defined)
    * m|makeiso      - make only iso image (without burn), Your image will be stored in /tmp directory
    * data=s         - set directory willth data to burn (default /tmp/burner)
    * name=s         - set name of iso file (defaultault cd.iso), You iso file will be stored in /tmp
    * burner=s       - set burner to use (default /dev/sr0)
