#compdef base-strap genfstab base-chroot

_base_strap_args=(
    '-h[display help]'
)

_base_strap_args_nonh=(
    '(-h --help)-c[Use the package cache on the host, rather than the target]'
    '(--help -h)-i[Avoid auto-confirmation of package selections]'
)


# builds command for invoking kepler in a _call_program command - extracts
# relevant options already specified (config file, etc)
# $cmd must be declared by calling function
_kepler_get_command() {
	# this is mostly nicked from _perforce
	cmd=( "kepler" "2>/dev/null")
	integer i
	for (( i = 2; i < CURRENT - 1; i++ )); do
		if [[ ${words[i]} = "--config" || ${words[i]} = "--root" ]]; then
			cmd+=( ${words[i,i+1]} )
		fi
	done
}

# provides completions for packages available from repositories
# these can be specified as either 'package' or 'repository/package'
_kepler_completions_all_packages() {
	local -a cmd packages repositories packages_long
	_kepler_get_command

	if compset -P1 '*/*'; then
		packages=( $(_call_program packages $cmd[@] -Sql ${words[CURRENT]%/*}) )
		typeset -U packages
		_wanted repo_packages expl "repository/package" compadd ${(@)packages}
	else
		packages=( $(_call_program packages $cmd[@] -Sql) )
		typeset -U packages
		_wanted packages expl "packages" compadd - "${(@)packages}"

		repositories=(${(o)${${${(M)${(f)"$(</etc/kepler.conf)"}:#\[*}/\[/}/\]/}:#options})
		typeset -U repositories
		_wanted repo_packages expl "repository/package" compadd -S "/" $repositories
	fi
}

_base_strap_none(){
    _arguments -s : \
        "$_base_strap_args[@]" \
        "$_longopts[@]" \
}

_genfstab_args=(
    '-h[display help]'
)
_genfstab_args_nonh=(
    '(--help -h)-p[Avoid printing pseudofs mounts]'
    '(-U --help -h)-L[Use labels for source identifiers]'
    '(-L --help -h)-U[Use UUIDs for source identifiers]'
)

_base_chroot_args=( '-h[display help]' )

_longopts=( '--help[display help]' )

_base_strap(){
    if [[ -z ${(M)words:#--help} && -z ${(M)words:#-h} ]]; then
        case $words[CURRENT] in
            -c*|-d*|-i*)
                _arguments -s "$_base_strap_args_nonh[@]"
                ;;
            -*)
                _arguments -s : \
                    "$_base_strap_args[@]" \
                    "$_base_strap_args_nonh[@]" \
                    "$_longopts[@]"
                ;;
            --*)
                _arguments -s : \
                    "$_longopts[@]"
                ;;
            *)
                _arguments -s : \
                    "$_base_strap_args[@]" \
                    "$_base_strap_args_nonh[@]" \
                    "$_longopts[@]" \
                    ":*:_path_files -/" \
                    ":*:_kepler_completions_all_packages"
                ;;
        esac
    else
        return 1
    fi
}

_genfstab(){
    if [[ -z ${(M)words:#--help} && -z ${(M)words:#-*h} ]]; then
        case $words[CURRENT] in
            -p*|-L*|-U*)
                _arguments -s : \
                    "$_genfstab_args_nonh[@]"
                ;;
            -*)
                _arguments -s : \
                    "$_genfstab_args[@]" \
                    "$_genfstab_args_nonh[@]" \
                    "$_longopts[@]"
                ;;
            --*)
                _arguments -s : \
                    "$_longopts[@]"
                ;;
            *)
                _arguments \
                    "$_genfstab_args[@]" \
                    "$_genfstab_args_nonh[@]" \
                    "$_longopts[@]" \
                    ":*:_path_files -/"
                ;;
        esac
    else
        return 1
    fi
}

_base_chroot(){
    if [[ -z ${(M)words:#--help} && -z ${(M)words:#-*h} ]]; then
        case $words[CURRENT] in
            -*)
                _arguments -s : \
                    "$_base_chroot_args[@]" \
                    "$_longopts[@]" \
                ;;
            --*)
                _arguments -s : \
                    "$_longopts[@]"
                ;;
            *)
                _arguments \
                    ':*:_path_files -/'
                ;;
        esac
    else
        return 1
    fi
}

_install_scripts(){
    case "$service" in
        base-strap)
            _base_strap "$@"
            ;;
        genfstab)
            _genfstab "$@";;
        base-chroot)
            _base_chroot "$@";;
        *)
            _message "Error";;
    esac
}

_install_scripts "$@"
