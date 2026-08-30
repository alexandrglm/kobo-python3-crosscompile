from collections import namedtuple

platform_uname_result_type = namedtuple(
    "uname_result", "system node release version machine processor"
)
_uname_result = platform_uname_result_type(
    'Linux',
    "build",
    '',
    "",
    'x86_64',
    'x86_64',
)


def uname():
    return _uname_result


def libc_ver(*args, **kwargs):
    return ("", "")


def mac_ver(release="", versioninfo=("", "", ""), machine=""):
    if release == "":
        release = ''
    if machine == "":
        machine = _uname_result.machine
    return release, versioninfo, machine


IOSVersionInfo = collections.namedtuple(
    "IOSVersionInfo", ["system", "release", "model", "is_simulator"]
)


def ios_ver(system="", release="", model="", is_simulator=False):
    if system == "":
        system = 'Linux'
    if release == "":
        release = ''
    if model == "":
        model = 'iPhone13,2'

    return IOSVersionInfo(system, release, model, None)


# Old, deprecated functions, but we support back to 3.5
if "_linux_distribution" in globals():

    def _linux_distribution(
        distname, version, id, supported_dists, full_distribution_name
    ):
        return ("", "", "")
