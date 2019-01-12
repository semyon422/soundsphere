local ffi = require("ffi")

ffi.cdef([[
extern __attribute__((dllimport)) int _libiconv_version;
typedef void* libiconv_t;
typedef long int ptrdiff_t;
typedef long unsigned int size_t;
typedef short unsigned int wchar_t;
typedef struct {
long long __max_align_ll __attribute__((__aligned__(__alignof__(long long))));
long double __max_align_ld __attribute__((__aligned__(__alignof__(long double))));
} max_align_t;
typedef int error_t;
typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef short int __int16_t;
typedef short unsigned int __uint16_t;
typedef int __int32_t;
typedef unsigned int __uint32_t;
typedef long int __int64_t;
typedef long unsigned int __uint64_t;
typedef signed char __int_least8_t;
typedef unsigned char __uint_least8_t;
typedef short int __int_least16_t;
typedef short unsigned int __uint_least16_t;
typedef int __int_least32_t;
typedef unsigned int __uint_least32_t;
typedef long int __int_least64_t;
typedef long unsigned int __uint_least64_t;
typedef long int __intmax_t;
typedef long unsigned int __uintmax_t;
typedef long int __intptr_t;
typedef long unsigned int __uintptr_t;
typedef __int64_t __blkcnt_t;
typedef __int32_t __blksize_t;
typedef __uint32_t __dev_t;
typedef unsigned long __fsblkcnt_t;
typedef unsigned long __fsfilcnt_t;
typedef __uint32_t __uid_t;
typedef __uint32_t __gid_t;
typedef __uint64_t __ino_t;
typedef long long __key_t;
typedef __uint16_t __sa_family_t;
typedef int __socklen_t;
typedef void *_LOCK_T;
void __cygwin_lock_init(_LOCK_T *);
void __cygwin_lock_init_recursive(_LOCK_T *);
void __cygwin_lock_fini(_LOCK_T *);
void __cygwin_lock_lock(_LOCK_T *);
int __cygwin_lock_trylock(_LOCK_T *);
void __cygwin_lock_unlock(_LOCK_T *);
typedef long _off_t;
typedef int __pid_t;
typedef __uint32_t __id_t;
typedef __uint32_t __mode_t;
__extension__ typedef long long _off64_t;
typedef _off_t __off_t;
typedef _off64_t __loff_t;
typedef long _fpos_t;
typedef _off64_t _fpos64_t;
typedef long unsigned int __size_t;
typedef long signed int _ssize_t;
typedef _ssize_t __ssize_t;
typedef unsigned int wint_t;
typedef struct
{
int __count;
union
{
wint_t __wch;
unsigned char __wchb[4];
} __value;
} _mbstate_t;
typedef _LOCK_T _flock_t;
typedef void *_iconv_t;
typedef unsigned long __clock_t;
typedef long __time_t;
typedef unsigned long __clockid_t;
typedef unsigned long __timer_t;
typedef unsigned short __nlink_t;
typedef long __suseconds_t;
typedef unsigned long __useconds_t;
typedef char * __va_list;
typedef unsigned int __ULong;
struct _reent;
struct __locale_t;
struct _Bigint
{
struct _Bigint *_next;
int _k, _maxwds, _sign, _wds;
__ULong _x[1];
};
struct __tm
{
int __tm_sec;
int __tm_min;
int __tm_hour;
int __tm_mday;
int __tm_mon;
int __tm_year;
int __tm_wday;
int __tm_yday;
int __tm_isdst;
};
struct _on_exit_args {
void * _fnargs[32];
void * _dso_handle[32];
__ULong _fntypes;
__ULong _is_cxa;
};
struct _atexit {
struct _atexit *_next;
int _ind;
void (*_fns[32])(void);
struct _on_exit_args _on_exit_args;
};
struct __sbuf {
unsigned char *_base;
int _size;
};
struct __sFILE {
unsigned char *_p;
int _r;
int _w;
short _flags;
short _file;
struct __sbuf _bf;
int _lbfsize;
void * _cookie;
_ssize_t (__attribute__((__cdecl__)) * _read) (struct _reent *, void *, char *, size_t)
;
_ssize_t (__attribute__((__cdecl__)) * _write) (struct _reent *, void *, const char *, size_t)
;
_fpos_t (__attribute__((__cdecl__)) * _seek) (struct _reent *, void *, _fpos_t, int);
int (__attribute__((__cdecl__)) * _close) (struct _reent *, void *);
struct __sbuf _ub;
unsigned char *_up;
int _ur;
unsigned char _ubuf[3];
unsigned char _nbuf[1];
struct __sbuf _lb;
int _blksize;
_off_t _offset;
struct _reent *_data;
_flock_t _lock;
_mbstate_t _mbstate;
int _flags2;
};
struct __sFILE64 {
unsigned char *_p;
int _r;
int _w;
short _flags;
short _file;
struct __sbuf _bf;
int _lbfsize;
struct _reent *_data;
void * _cookie;
_ssize_t (__attribute__((__cdecl__)) * _read) (struct _reent *, void *, char *, size_t)
;
_ssize_t (__attribute__((__cdecl__)) * _write) (struct _reent *, void *, const char *, size_t)
;
_fpos_t (__attribute__((__cdecl__)) * _seek) (struct _reent *, void *, _fpos_t, int);
int (__attribute__((__cdecl__)) * _close) (struct _reent *, void *);
struct __sbuf _ub;
unsigned char *_up;
int _ur;
unsigned char _ubuf[3];
unsigned char _nbuf[1];
struct __sbuf _lb;
int _blksize;
int _flags2;
_off64_t _offset;
_fpos64_t (__attribute__((__cdecl__)) * _seek64) (struct _reent *, void *, _fpos64_t, int);
_flock_t _lock;
_mbstate_t _mbstate;
};
typedef struct __sFILE64 __FILE;
struct _glue
{
struct _glue *_next;
int _niobs;
__FILE *_iobs;
};
struct _rand48 {
unsigned short _seed[3];
unsigned short _mult[3];
unsigned short _add;
};
struct _reent
{
int _errno;
__FILE *_stdin, *_stdout, *_stderr;
int _inc;
char _emergency[25];
int _unspecified_locale_info;
struct __locale_t *_locale;
int __sdidinit;
void (__attribute__((__cdecl__)) * __cleanup) (struct _reent *);
struct _Bigint *_result;
int _result_k;
struct _Bigint *_p5s;
struct _Bigint **_freelist;
int _cvtlen;
char *_cvtbuf;
union
{
struct
{
unsigned int _unused_rand;
char * _strtok_last;
char _asctime_buf[26];
struct __tm _localtime_buf;
int _gamma_signgam;
__extension__ unsigned long long _rand_next;
struct _rand48 _r48;
_mbstate_t _mblen_state;
_mbstate_t _mbtowc_state;
_mbstate_t _wctomb_state;
char _l64a_buf[8];
char _signal_buf[24];
int _getdate_err;
_mbstate_t _mbrlen_state;
_mbstate_t _mbrtowc_state;
_mbstate_t _mbsrtowcs_state;
_mbstate_t _wcrtomb_state;
_mbstate_t _wcsrtombs_state;
int _h_errno;
} _reent;
struct
{
unsigned char * _nextf[30];
unsigned int _nmalloc[30];
} _unused;
} _new;
struct _atexit *_atexit;
struct _atexit _atexit0;
void (**(_sig_func))(int);
struct _glue __sglue;
__FILE __sf[3];
};
extern struct _reent *_impure_ptr ;
extern struct _reent *const _global_impure_ptr ;
void _reclaim_reent (struct _reent *);
struct _reent * __attribute__((__cdecl__)) __getreent (void);
extern int *__errno (void);
extern __attribute__((dllimport)) const char * const _sys_errlist[];
extern __attribute__((dllimport)) int _sys_nerr;
extern __attribute__((dllimport)) const char * const sys_errlist[];
extern __attribute__((dllimport)) int sys_nerr;
extern __attribute__((dllimport)) char *program_invocation_name;
extern __attribute__((dllimport)) char *program_invocation_short_name;
extern __attribute__((dllimport)) libiconv_t libiconv_open (const char* tocode, const char* fromcode);
extern __attribute__((dllimport)) size_t libiconv (libiconv_t cd, const char* * inbuf, size_t *inbytesleft, char* * outbuf, size_t *outbytesleft);
extern __attribute__((dllimport)) int libiconv_close (libiconv_t cd);
extern __attribute__((dllimport)) int libiconvctl (libiconv_t cd, int request, void* argument);
extern __attribute__((dllimport)) void libiconvlist (int (*do_one) (unsigned int namescount,
const char * const * names,
void* data),
void* data);
extern __attribute__((dllimport)) void libiconv_set_relocation_prefix (const char *orig_prefix,
const char *curr_prefix);
]])

local libcharset = ffi.load("libcharset-1")
local libiconv = ffi.load("libiconv-2")

return function(instr, tocode, fromcode, outbuff_size)
	local cd = libiconv.libiconv_open(tocode, fromcode)
	
	local out = {}
	
	local outbuff_size = outbuff_size or #instr * 4
	local outbuff = ffi.new("char[?]", outbuff_size)
	
	local inbuff_size = #instr
	local inbuff = ffi.new("char[?]", #instr)
	ffi.copy(inbuff, instr, #instr)
	
	local inbuff_ptr = ffi.new("const char*[1]", inbuff)
	local outbuff_ptr = ffi.new("char*[1]", outbuff)
	local inbytesleft = ffi.new("size_t[1]", inbuff_size)
	local outbytesleft = ffi.new("size_t[1]", outbuff_size)

	while inbytesleft[0] ~= 0 do
		local err = libiconv.libiconv(cd, inbuff_ptr, inbytesleft, outbuff_ptr, outbytesleft)
		if err ~= 0 then
			libiconv.libiconv_close(cd)
			return
		end
		table.insert(out, ffi.string(outbuff, outbuff_size - outbytesleft[0]))
		outbytesleft[0] = outbuff_size
		outbuff_ptr[0] = outbuff_ptr[0] - outbuff_size
	end 
	
	inbuff_ptr[0] = inbuff_ptr[0] - inbuff_size
	libiconv.libiconv(cd, nil, nil, nil, nil)
	libiconv.libiconv_close(cd)
	
	return table.concat(out)
end
