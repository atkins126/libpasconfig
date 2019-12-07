(******************************************************************************)
(*                                libPasConfig                                *)
(*              object pascal wrapper around libconfig library                *)
(*                  https://github.com/hyperrealm/libconfig                   *)
(*                                                                            *)
(* Copyright (c) 2019                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpasconfig                ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)

unit libpasconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{$IFDEF FPC}
  {$PACKRECORDS C}
{$ENDIF}

{$IFDEF WINDOWS}
  const libConfig = 'libconfig.dll';
{$ENDIF}
{$IFDEF LINUX}
  const libConfig = 'libconfig.so';
{$ENDIF}

{$IFNDEF LIBCONFIG_VER_MAJOR}
  {$DEFINE LIBCONFIG_VER_MAJOR 1}
{$ENDIF}
{$IFNDEF LIBCONFIG_VER_MINOR}
  {$DEFINE LIBCONFIG_VER_MINOR 5}
{$ENDIF}
{$IFNDEF LIBCONFIG_VER_REVISION}
  {$DEFINE LIBCONFIG_VER_REVISION 0}
{$ENDIF}

const
  CONFIG_TYPE_NONE                                                      = 0;
  CONFIG_TYPE_GROUP                                                     = 1;
  CONFIG_TYPE_INT                                                       = 2;
  CONFIG_TYPE_INT64                                                     = 3;
  CONFIG_TYPE_FLOAT                                                     = 4;
  CONFIG_TYPE_STRING                                                    = 5;
  CONFIG_TYPE_BOOL                                                      = 6;
  CONFIG_TYPE_ARRAY                                                     = 7;
  CONFIG_TYPE_LIST                                                      = 8;

  CONFIG_FORMAT_DEFAULT                                                 = 0;
  CONFIG_FORMAT_HEX                                                     = 1;

  CONFIG_OPTION_AUTOCONVERT                                             = $0001;
  CONFIG_OPTION_SEMICOLON_SEPARATORS                                    = $0002;
  CONFIG_OPTION_COLON_ASSIGNMENT_FOR_GROUPS                             = $0004;
  CONFIG_OPTION_COLON_ASSIGNMENT_FOR_NON_GROUPS                         = $0008;
  CONFIG_OPTION_OPEN_BRACE_ON_SEPARATE_LINE                             = $0010;
  {$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
          LIBCONFIG_VER_MINOR    >= 7 AND
          LIBCONFIG_VER_REVISION >= 0}
  CONFIG_OPTION_ALLOW_SCIENTIFIC_NOTATION                               = $0020;
  CONFIG_OPTION_FSYNC                                                   = $0040;
  {$ENDIF}

  CONFIG_TRUE                                                           = 1;
  CONFIG_FALSE                                                          = 0;

type
  pconfig_error_t = ^config_error_t;
  config_error_t = (
    CONFIG_ERR_NONE                                                     = 0,
    CONFIG_ERR_FILE_IO                                                  = 1,
    CONFIG_ERR_PARSE                                                    = 2
  );

  pconfig_list_t = ^config_list_t;

  pconfig_value_t = ^config_value_t;
  config_value_t = record
    case byte of
    1 : (ival : Integer);
    2 : (llval : Int64);
    3 : (fval : Double);
    4 : (sval : PChar);
    5 : (list : pconfig_list_t);
  end;

  pconfig_t = ^config_t;

  ppconfig_setting_t = ^pconfig_setting_t;
  pconfig_setting_t = ^config_setting_t;
  config_setting_t = record
    name : PChar;
    settings_type : Smallint;
    format : Smallint;
    value : config_value_t;
    parent : pconfig_settings_t;
    config : pconfig_t;
    hook : Pointer;
    line : Cardinal;
    file_name : PChar;
  end;

  config_list_t = record
    length : Cardinal;
    elements : ppconfig_settings_t;
  end;

  PPChar = ^PChar;

  destructor_fn_t = procedure (obj : Pointer) of object;
  {$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
          LIBCONFIG_VER_MINOR    >= 7 AND
          LIBCONFIG_VER_REVISION >= 0}
  config_include_fn_t = function (config : pconfig_t; const include_dir : PChar;
    const path : PChar; const error : PPChar) : PPChar of object;
  {$ENDIF}

  config_t = record
    root : pconfig_settings_t;
    destructor_callback : destructor_fn_t;
    options : Integer;
    tab_width : Word;
    {$IFDEF LIBCONFIG_VER_MAJOR    <= 1 AND
            LIBCONFIG_VER_MINOR    <= 5 AND
            LIBCONFIG_VER_REVISION <= 0}
    default_format : Smallint;
    {$ENDIF}
    {$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
            LIBCONFIG_VER_MINOR    >= 7 AND
            LIBCONFIG_VER_REVISION >= 0}
    float_precision : Word;
    default_format : Word;
    {$ENDIF}
    include_dir : PChar;
    {$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
            LIBCONFIG_VER_MINOR    >= 7 AND
            LIBCONFIG_VER_REVISION >= 0}
    include_fn : config_include_fn_t;
    {$ENDIF}
    error_text : PChar;
    error_file : PChar;
    error_line : Integer;
    error_type : config_error_t;
    filenames : PPChar;
    num_filenames : Cardinal;
    {$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
            LIBCONFIG_VER_MINOR    >= 7 AND
            LIBCONFIG_VER_REVISION >= 0}
    hook : Pointer;
    {$ENDIF}
  end;

{ Initializes the config_t structure pointed to by config as a new, empty
  configuration. }
procedure config_init (config : pconfig_t); cdecl; external libConfig;

{ Destroys the configuration config, deallocating all memory associated with the
  configuration, but does not attempt to deallocate the config_t structure
  itself. }
procedure config_destroy (config : pconfig_t); cdecl; external libConfig;

{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
{ This function clears the configuration config. All child settings of the root
  setting are recursively destroyed. All other attributes of the configuration
  are left unchanged. }
procedure config_clear (config : pconfig_t); cdecl; external libConfig;
{$ENDIF}

{ This function reads and parses a configuration from the given stream into the
  configuration object config. It returns CONFIG_TRUE on success, or
  CONFIG_FALSE on failure; the config_error_text(), config_error_file(),
  config_error_line(), and config_error_type() functions, described below, can
  be used to obtain information about the error. }
function config_read (config : pconfig_t; stream : Pointer) : Integer; cdecl;
  external libConfig;

{ This function reads and parses a configuration from the file named filename
  into the configuration object config. It returns CONFIG_TRUE on success, or
  CONFIG_FALSE on failure; the config_error_text() and config_error_line()
  functions, described below, can be used to obtain information about the
  error. }
function config_read_file (config : pconfig_t; const filename : PChar) :
  Integer; cdecl; external libConfig;

{ This function reads and parses a configuration from the string str into the
  configuration object config. It returns CONFIG_TRUE on success, or
  CONFIG_FALSE on failure; the config_error_text() and config_error_line()
  functions, described below, can be used to obtain information about the
  error. }
function config_read_string (config : pconfig_t; const str : PChar) : Integer;
  cdecl; external libConfig;

{ This function writes the configuration config to the given stream. }
procedure config_write (const config : pconfig_t; stream : Pointer); cdecl;
  external libConfig;

{ This function writes the configuration config to the file named filename. It
  returns CONFIG_TRUE on success, or CONFIG_FALSE on failure. }
function config_write_file (config : pconfig_t; const filename : PChar) :
  Integer; cdecl; external libConfig;

{ These functions, which are implemented as macros, return the text, filename,
  and line number of the parse error, if one occurred during a call to
  config_read(), config_read_string(), or config_read_file(). Storage for the
  strings returned by config_error_text() and config_error_file() are managed by
  the library and released automatically when the configuration is destroyed;
  these strings must not be freed by the caller. If the error occurred in text
  that was read from a string or stream, config_error_file() will return NULL. }
function config_error_text (const config : pconfig_t) : PChar; inline;
function config_error_file (const config : pconfig_t) : PChar; inline;
function config_error_line (const config : pconfig_t) : Integer; inline;

{ This function, which is implemented as a macro, returns the type of error that
  occurred during the last call to one of the read or write functions. The
  config_error_t type is an enumeration with the following values:
  CONFIG_ERR_NONE, CONFIG_ERR_FILE_IO, CONFIG_ERR_PARSE. These represent
  success, a file I/O error, and a parsing error, respectively. }
function config_error_type (const config : pconfig_t) : config_error_t; inline;

{ config_set_include_dir() specifies the include directory, include_dir,
  relative to which the files specified in ‘@include’ directives will be located
  for the configuration config. By default, there is no include directory, and
  all include files are expected to be relative to the current working
  directory. If include_dir is NULL, the default behavior is reinstated.

  For example, if the include directory is set to /usr/local/etc, the include
  directive ‘@include "configs/extra.cfg"’ would include the file
  /usr/local/etc/configs/extra.cfg.

  config_get_include_dir() returns the current include directory for the
  configuration config, or NULL if none is set. }
procedure config_set_include_dir (config : pconfig_t; const include_dir :
  PChar); cdecl; external libConfig;
function config_get_include_dir (const config : pconfig_t) : PChar; inline;

{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
{ Specifies the include function func to use when processing include directives.
  If func is NULL, the default include function, config_default_include_func(),
  will be reinstated.

  The type config_include_fn_t is a type alias for a function whose signature
  is:

  Function: const char ** func (config_t *config, const char *include_dir,
  const char *path, const char **error)

        The function receives the configuration config, the configuration’s
        current include directory include_dir, the argument to the include
        directive path; and a pointer at which to return an error message error.

        On success, the function should return a NULL-terminated array of paths.
        Any relative paths must be relative to the program’s current working
        directory. The contents of these files will be inlined at the point of
        inclusion, in the order that the paths appear in the array. Both the
        array and its elements should be heap allocated; the library will take
        ownership of and eventually free the strings in the array and the array
        itself.

        On failure, the function should return NULL and set *error to a static
        error string which should be used as the parse error for the
        configuration; the library does not take ownership of or free this
        string.

        The default include function, config_default_include_func(), simply
        returns a NULL-terminated array containing either a copy of path if it’s
        an absolute path, or a concatenation of include_dir and path if it’s a
        relative path.

  Application-supplied include functions can perform custom tasks like wildcard
  expansion or variable substitution. For example, consider the include
  directive:

  @include "configs/*.cfg"

  The include function would be invoked with the path ‘configs/*.cfg’ and could
  do wildcard expansion on that path, returning a list of paths to files with
  the file extension ‘.cfg’ in the subdirectory ‘configs’. Each of these files
  would then be inlined at the location of the include directive.

  Tasks like wildcard expansion and variable substitution are non-trivial to
  implement and typically require platform-specific code. In the interests of
  keeping the library as compact and platform-independent as possible,
  implementations of such include functions are not included. }
procedure config_set_include_func (config : pconfig_t; func :
  config_include_fn_t); cdecl; external libConfig;
{$ENDIF}

{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
{ These functions get and set the number of decimal digits to output after the
  radix character when writing the configuration to a file or stream.

  Valid values for digits range from 0 (no decimals) to about 15 (implementation
  defined). This parameter has no effect on parsing.

  The default float precision is 6. }
function config_get_float_precision (const config : pconfig_t) : Word; cdecl;
  external libConfig;
procedure config_set_float_precision (config : pconfig_t; digits : Word); cdecl;
  external libConfig;
{$ENDIF}

{ These functions get and set the options for the configuration config. The
  options affect how configurations are read and written. The following options
  are defined:

    CONFIG_OPTION_AUTOCONVERT
        Turning this option on enables number auto-conversion for the
        configuration. When this feature is enabled, an attempt to retrieve a
        floating point setting’s value into an integer (or vice versa), or store
        an integer to a floating point setting’s value (or vice versa) will
        cause the library to silently perform the necessary conversion (possibly
        leading to loss of data), rather than reporting failure. By default this
        option is turned off.

    CONFIG_OPTION_SEMICOLON_SEPARATORS
        This option controls whether a semicolon (‘;’) is output after each
        setting when the configuration is written to a file or stream. (The
        semicolon separators are optional in the configuration syntax.) By
        default this option is turned on.

    CONFIG_OPTION_COLON_ASSIGNMENT_FOR_GROUPS
        This option controls whether a colon (‘:’) is output between each group
        setting’s name and its value when the configuration is written to a file
        or stream. If the option is turned off, an equals sign (‘=’) is output
        instead. (These tokens are interchangeable in the configuration syntax.)
        By default this option is turned on.

    CONFIG_OPTION_COLON_ASSIGNMENT_FOR_NON_GROUPS
        This option controls whether a colon (‘:’) is output between each
        non-group setting’s name and its value when the configuration is written
        to a file or stream. If the option is turned off, an equals sign (‘=’)
        is output instead. (These tokens are interchangeable in the
        configuration syntax.) By default this option is turned off.

    CONFIG_OPTION_OPEN_BRACE_ON_SEPARATE_LINE
        This option controls whether an open brace (‘{’) will be written on its
        own line when the configuration is written to a file or stream. If the
        option is turned off, the brace will be written at the end of the
        previous line. By default this option is turned on.

    CONFIG_OPTION_ALLOW_SCIENTIFIC_NOTATION
        (Since v1.7) This option controls whether scientific notation may be
        used as appropriate when writing floating point values (corresponding
        to printf() ‘%g’ format) or should never be used (corresponding to
        printf() ‘%f’ format). By default this option is turned off.

    CONFIG_OPTION_FSYNC
        (Since v1.7.1) This option controls whether the config_write_file()
        function performs an fsync operation after writing the configuration and
        before closing the file. By default this option is turned off. }}
function config_get_options (const config : pconfig_t) : Integer; cdecl;
  external libConfig;
procedure config_set_options (config : pconfig_t; options : Integer); cdecl;
  external libConfig;

{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
{ These functions get and set the given option of the configuration config. The
  option is enabled if flag is CONFIG_TRUE and disabled if it is CONFIG_FALSE.

  See config_set_options() above for the list of available options. }
function config_get_option (const config : pconfig_t; option : Integer) :
  Integer; cdecl; external libConfig;
procedure config_set_option (config : pconfig_t; option : Integer; flag :
  Integer); cdecl; external libConfig;
{$ENDIF}

{$IFDEF LIBCONFIG_VER_MAJOR    <= 1 AND
        LIBCONFIG_VER_MINOR    <= 5 AND
        LIBCONFIG_VER_REVISION <= 0}
{ These functions get and set the CONFIG_OPTION_AUTO_CONVERT option. They are
  obsoleted by the config_set_option() and config_get_option() functions
  described above. }
function config_get_auto_convert (const config : pconfig_t) : Integer; cdecl;
  external libConfig;
procedure config_set_auto_convert (config : pconfig_t; flag : Integer); cdecl;
  external libConfig;
{$ENDIF}
{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
{ These functions get and set the CONFIG_OPTION_AUTO_CONVERT option. They are
  obsoleted by the config_set_option() and config_get_option() functions
  described above. }
function config_get_auto_convert (const config : pconfig_t) : Integer; inline;
procedure config_set_auto_convert (config : pconfig_t; flag : Integer); inline;
{$ENDIF}

{ These functions, which are implemented as macros, get and set the default
  external format for settings in the configuration config. If a non-default
  format has not been set for a setting with config_setting_set_format(), this
  configuration-wide default format will be used instead when that setting is
  written to a file or stream.}
function config_get_default_format (config : pconfig_t) : Word; inline;
procedure config_set_default_format (config : pconfig_t; format : Word); inline;

{ These functions, which are implemented as macros, get and set the tab width
  for the configuration config. The tab width affects the formatting of the
  configuration when it is written to a file or stream: each level of nesting is
  indented by width spaces, or by a single tab character if width is 0. The tab
  width has no effect on parsing.

  Valid tab widths range from 0 to 15. The default tab width is 2. }
function config_get_tab_width (const config : pconfig_t) : Word; inline;
procedure config_set_tab_Width (config : pconfig_t; width : Word); inline;

{ These functions look up the value of the setting in the configuration config
  specified by the path path. They store the value of the setting at value and
  return CONFIG_TRUE on success. If the setting was not found or if the type of
  the value did not match the type requested, they leave the data pointed to by
  value unmodified and return CONFIG_FALSE.

  Storage for the string returned by config_lookup_string() is managed by the
  library and released automatically when the setting is destroyed or when the
  setting’s value is changed; the string must not be freed by the caller. }
function config_lookup_int (const config : pconfig_t; const path : PChar;
  value : PInteger) : Integer; cdecl; external libConfig;
function config_lookup_int64 (const config : pconfig_t; const path : PChar;
  value : PInt64) : Integer; cdecl; external libConfig;
function config_lookup_float (const config : pconfig_t; const path : PChar;
  value : PDouble) : Integer; cdecl; external libConfig;
function config_lookup_bool (const config : pconfig_t; const path : PChar;
  value : PInteger) : Integer; cdecl; external libConfig;
function config_lookup_string (const config : pconfig_t; const path : PChar;
  value : PPChar) : Integer; cdecl; external libConfig;

{ This function locates the setting in the configuration config specified by the
  path path. It returns a pointer to the config_setting_t structure on success,
  or NULL if the setting was not found. }
function config_lookup (const config : pconfig_t; const path : PChar) :
  pconfig_setting_t; cdecl; external libConfig;

{ This function locates a setting by a path path relative to the setting
  setting. It returns a pointer to the config_setting_t structure on success, or
  NULL if the setting was not found. }
function config_setting_lookup (setting : pconfig_setting_t; const path :
  PChar) : pconfig_setting_t; cdecl; external libConfig;

{ These functions return the value of the given setting. If the type of the
  setting does not match the type requested, a 0 or NULL value is returned.
  Storage for the string returned by config_setting_get_string() is managed by
  the library and released automatically when the setting is destroyed or when
  the setting’s value is changed; the string must not be freed by the caller. }
function config_setting_get_int (const setting : pconfig_setting_t) : Integer;
  cdecl; external libConfig;
function config_setting_get_int64 (const setting : pconfig_setting_t) :
  Int64; cdecl; external libConfig;
function config_setting_get_float (const setting : pconfig_setting_t) :
  Double; cdecl; external libConfig;
function config_setting_get_bool (const setting : pconfig_setting_t) :
  Integer; cdecl; external libConfig;
function config_setting_get_string (const setting : pconfig_setting_t) :
  PChar; cdecl; external libConfig;

{ These functions set the value of the given setting to value. On success, they
  return CONFIG_TRUE. If the setting does not match the type of the value, they
  return CONFIG_FALSE. config_setting_set_string() makes a copy of the passed
  string value, so it may be subsequently freed or modified by the caller
  without affecting the value of the setting. }
function config_setting_set_int (setting : pconfig_setting_t; value : Integer) :
  Integer; cdecl; external libConfig;
function config_setting_set_int64 (setting : pconfig_setting_t; value : Int64) :
  Integer; cdecl; external libConfig;
function config_setting_set_float (setting : pconfig_setting_t; value : Double)
  : Integer; cdecl; external libConfig;
function config_setting_set_bool (setting : pconfig_setting_t; value : Integer)
  : Integer; cdecl; external libConfig;
function config_setting_set_string (setting : pconfig_setting_t; const value :
  PChar) : Integer; cdecl; external libConfig;

{ These functions look up the value of the child setting named name of the
  setting setting. They store the value at value and return CONFIG_TRUE on
  success. If the setting was not found or if the type of the value did not
  match the type requested, they leave the data pointed to by value unmodified
  and return CONFIG_FALSE.

  Storage for the string returned by config_setting_lookup_string() is managed
  by the library and released automatically when the setting is destroyed or
  when the setting’s value is changed; the string must not be freed by the
  caller. }
function config_setting_lookup_int (const setting : pconfig_setting_t; const
  name : PChar; value : PInteger) : Integer; cdecl; external libConfig;
function config_setting_lookup_int64 (const setting : pconfig_setting_t; const
  name : PChar; value : PInt64) : Integer; cdecl; external libConfig;
function config_setting_lookup_float (const setting : pconfig_setting_t; const
  name : PChar; value : PDouble) : Integer; cdecl; external libConfig;
function config_setting_lookup_bool (const setting : pconfig_setting_t; const
  name : PChar; value : PInteger) : Integer; cdecl; external libConfig;
function config_setting_lookup_string (const setting : pconfig_setting_t; const
  name : PChar; value : PPChar); cdecl; external libConfig;




implementation

function config_error_text(const config: pconfig_t): PChar;
begin
  Result := config^.error_text;
end;

function config_error_file(const config: pconfig_t): PChar;
begin
  Result := config^.error_file;
end;

function config_error_line(const config: pconfig_t): Integer;
begin
  Result := config^.error_line;
end;

function config_error_type(const config: pconfig_t): config_error_t;
begin
  Result := config^.error_type;
end;

function config_get_include_dir(const config: pconfig_t): PChar;
begin
  Result := config^.include_dir;
end;

{$IFDEF LIBCONFIG_VER_MAJOR    >= 1 AND
        LIBCONFIG_VER_MINOR    >= 7 AND
        LIBCONFIG_VER_REVISION >= 0}
function config_get_auto_convert(const config: pconfig_t): Integer;
begin
  Result := config_get_option(config, CONFIG_OPTION_AUTOCONVERT);
end;

procedure config_set_auto_convert(config: pconfig_t; flag: Integer);
begin
  config_set_option(config, CONFIG_OPTION_AUTOCONVERT, flag);
end;
{$ENDIF}

function config_get_default_format(config: pconfig_t): Word;
begin
  Result := config^.default_format;
end;

procedure config_set_default_format(config: pconfig_t; format: Word);
begin
  config^.default_format := format;
end;

function config_get_tab_width(const config: pconfig_t): Word;
begin
  Result := config^.tab_width;
end;

procedure config_set_tab_Width(config: pconfig_t; width: Word);
begin
  config^.tab_width := width;
end;



end.

