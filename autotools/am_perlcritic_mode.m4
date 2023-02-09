AC_DEFUN([PERLCRITIC_MODE], [

    AC_MSG_CHECKING([[whether to enable build mode]])

    AC_ARG_ENABLE([perlcritic_mode],
        [[  --enable-perlcritic-mode       configure mode (disables certain checks), default: true]],

        dnl AC_ARG_ENABLE: option if given
        [
            case "${enableval}" in
                yes)  perlcritic_mode=true  ;;
                no)   perlcritic_mode=false ;;
                *)
                    AC_MSG_ERROR([bad value ("$enableval") for '--enable-rpm-build-mode' option])
                    ;;
            esac
        ],

        dnl AC_ARG_ENABLE: option if not given
        [
            perlcritic_mode=true
        ]
    )

    if ${perlcritic_mode}; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
    fi

    dnl register a conditional for use in Makefile.am files
    AM_CONDITIONAL([PERLCRITIC_MODE_ENABLED], [${perlcritic_mode}])
])
