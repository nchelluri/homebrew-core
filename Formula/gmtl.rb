class Gmtl < Formula
  desc "Lightweight math library"
  homepage "https://ggt.sourceforge.io/"
  head "https://svn.code.sf.net/p/ggt/code/trunk"

  stable do
    url "https://downloads.sourceforge.net/project/ggt/Generic%20Math%20Template%20Library/0.6.1/gmtl-0.6.1.tar.gz"
    sha256 "f7d8e6958d96a326cb732a9d3692a3ff3fd7df240eb1d0921a7c5c77e37fc434"

    # Build assumes that Python is a framework, which isn't always true. See:
    # https://sourceforge.net/p/ggt/bugs/22/
    # The SConstruct from gmtl's HEAD doesn't need to be patched
    patch :DATA
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "f69dd084cade396219047d066439043e0aaa689797082ee207db7a1335787286" => :mojave
    sha256 "66ae5e3ccd2a0cbf4608b4ffee45bccb9c3be33148af25787c76652c1c0967ac" => :high_sierra
    sha256 "ee8d0c9f5f52453421a189c040459b5126a5b739231493a3e39d331c934c6478" => :sierra
    sha256 "8aa9f0f1fb77376dd333bb03e9c5a07f6457b76008a74018a932dca930148606" => :el_capitan
    sha256 "5e6d70f957f11e58d8b3cd24d5474a8bedc73e0aec6df13f85322f4fda8a1164" => :mavericks
    sha256 "ffeb26dd58a9b05a4427ca02392f93f9d5b352af790e536e4d2989baa81e4faf" => :mountain_lion
    sha256 "568a43df4aebd32ab9638d2725721b9c062bca0ecb778dbffb67fafd926d4a1a" => :lion
  end

  depends_on "scons" => :build

  # The scons script in gmtl only works for gcc, patch it
  # https://sourceforge.net/p/ggt/bugs/28/
  patch do
    url "https://gist.githubusercontent.com/anonymous/c16cad998a4903e6b3a8/raw/e4669b3df0e14996c7b7b53937dd6b6c2cbc7c04/gmtl_Sconstruct.diff"
    sha256 "1167f89f52f88764080d5760b6d054036734b26c7fef474692ff82e9ead7eb3c"
  end

  def install
    scons "install", "prefix=#{prefix}"
  end
end

__END__
diff --git a/SConstruct b/SConstruct
index 8326a89..2eb7ff0 100644
--- a/SConstruct
+++ b/SConstruct
@@ -126,7 +126,9 @@ def BuildDarwinEnvironment():
 
    exp = re.compile('^(.*)\/Python\.framework.*$')
    m = exp.search(distutils.sysconfig.get_config_var('prefix'))
-   framework_opt = '-F' + m.group(1)
+   framework_opt = None
+   if m:
+      framework_opt = '-F' + m.group(1)
 
    CXX = os.environ.get("CXX", WhereIs('g++'))
 
@@ -138,7 +140,10 @@ def BuildDarwinEnvironment():
 
    LINK = CXX
    CXXFLAGS = ['-ftemplate-depth-256', '-DBOOST_PYTHON_DYNAMIC_LIB',
-               '-Wall', framework_opt, '-pipe']
+               '-Wall', '-pipe']
+
+   if framework_opt is not None:
+      CXXFLAGS.append(framework_opt)
 
    compiler_ver       = match_obj.group(1)
    compiler_major_ver = int(match_obj.group(2))
@@ -152,7 +157,10 @@ def BuildDarwinEnvironment():
          CXXFLAGS += ['-Wno-long-double', '-no-cpp-precomp']
 
    SHLIBSUFFIX = distutils.sysconfig.get_config_var('SO')
-   SHLINKFLAGS = ['-bundle', framework_opt, '-framework', 'Python']
+   SHLINKFLAGS = ['-bundle']
+
+   if framework_opt is not None:
+      SHLINKFLAGS.extend([framework_opt, '-framework', 'Python'])
    LINKFLAGS = []
 
    # Enable profiling?
