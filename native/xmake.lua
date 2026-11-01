set_project("LSCNativeBridge")
set_version("0.9.5")
set_arch("x64")
set_languages("c++23")
add_rules("mode.debug", "mode.release", "mode.releasedbg")
option("commonlibsf_dir")
    set_default("deps/commonlibsf")
    set_showmenu(true)
option_end()
option("diagnostic_no_gameplay_reads")
    set_default(false)
    set_showmenu(true)
option_end()
includes(path.join(os.getenv("LSC_COMMONLIBSF") or "deps/commonlibsf", "xmake.lua"))
target("LSCNativeBridge")
    add_rules("commonlibsf.plugin", {
        name = "Transit Report Native Bridge",
        author = "Transit Report",
        description = "Experimental read-only player snapshot for loading-screen information"
    })
    add_files("src/*.cpp")
    if has_config("diagnostic_no_gameplay_reads") then
        add_defines("LSC_DIAGNOSTIC_NO_GAMEPLAY_READS")
    end
    add_syslinks("user32","shell32","ole32")
    set_installdir("staged")
