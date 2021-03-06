
//+------------------------------------------------------------------+
//|                                                      SHA512+HMAC |
//|                                                   Copyright 2017 |
//| http://www.zedwood.com/article/cpp-sha512-function               |
//| https://ru.wikipedia.org/wiki/HMAC                               |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017"
#property link      "http://www.zedwood.com/article/cpp-sha512-function"
#property version   "1.00"
#property strict

#define SHA384_512_BLOCK_SIZE 128 //=1024/8
#define DIGEST_SIZE 64 //=512/8

#define SHA2_SHFR(x, n)    (x >> n)
#define SHA2_ROTR(x, n)   ((x >> n) | (x << ((sizeof(x) << 3) - n)))
#define SHA2_ROTL(x, n)   ((x << n) | (x >> ((sizeof(x) << 3) - n)))
#define SHA2_CH(x, y, z)  ((x & y) ^ (~x & z))
#define SHA2_MAJ(x, y, z) ((x & y) ^ (x & z) ^ (y & z))
#define SHA512_F1(x) (SHA2_ROTR(x, 28) ^ SHA2_ROTR(x, 34) ^ SHA2_ROTR(x, 39))
#define SHA512_F2(x) (SHA2_ROTR(x, 14) ^ SHA2_ROTR(x, 18) ^ SHA2_ROTR(x, 41))
#define SHA512_F3(x) (SHA2_ROTR(x,  1) ^ SHA2_ROTR(x,  8) ^ SHA2_SHFR(x,  7))
#define SHA512_F4(x) (SHA2_ROTR(x, 19) ^ SHA2_ROTR(x, 61) ^ SHA2_SHFR(x,  6))

//------------------------------------------------------------------ class SHA512
class SHA512
{
protected:
static ulong sha512_k[80];
uint m_tot_len, m_len;
uchar m_block[2*SHA384_512_BLOCK_SIZE];
ulong m_h[8];

public:
void init()
{
m_h[0]=0x6a09e667f3bcc908; m_h[1]=0xbb67ae8584caa73b; m_h[2]=0x3c6ef372fe94f82b; m_h[3]=0xa54ff53a5f1d36f1;
m_h[4]=0x510e527fade682d1; m_h[5]=0x9b05688c2b3e6c1f; m_h[6]=0x1f83d9abfb41bd6b;  m_h[7]=0x5be0cd19137e2179;
m_len=0; m_tot_len=0;
}
void update(const uchar& message[], uint len)
{
uint tmp_len=SHA384_512_BLOCK_SIZE-m_len;
uint rem_len=len<tmp_len?len:tmp_len;
ArrayCopy(m_block, message, m_len, 0, rem_len); //memcpy(&m_block[m_len], message, rem_len);
if (m_len+len<SHA384_512_BLOCK_SIZE) { m_len+=len; return; }
uint new_len=len-rem_len;
uint block_nb=new_len/SHA384_512_BLOCK_SIZE;
uchar shifted_message[];
ArrayCopy(shifted_message, message, 0, rem_len); //shifted_message=message + rem_len;
transform(m_block, 1);
transform(shifted_message, block_nb);
rem_len=new_len%SHA384_512_BLOCK_SIZE;
ArrayCopy(m_block, shifted_message, 0, block_nb<<7, rem_len); //memcpy(m_block, &shifted_message[block_nb << 7], rem_len);
m_len=rem_len;
m_tot_len+=(block_nb + 1)<<7;
}
void end(uchar& digest[])
{
uint block_nb=1+((SHA384_512_BLOCK_SIZE-17)<(m_len%SHA384_512_BLOCK_SIZE));
uint len_b=(m_tot_len+m_len)<<3;
uint pm_len=block_nb<<7;
ArrayFill(m_block, m_len, pm_len-m_len, 0); //memset(m_block+m_len, 0, pm_len-m_len);
m_block[m_len]=0x80;
SHA2_UNPACK32(len_b, m_block, pm_len-4);
transform(m_block, block_nb);
for (int i=0; i<8; i++) SHA2_UNPACK64(m_h[i], digest, i<<3);
}

protected:
void transform(const uchar& message[], uint block_nb)
{
for (int i=0; i<(int)block_nb; i++)
{
uchar sub_block[]; ArrayCopy(sub_block, message, 0, (i<<7)); //sub_block=message+(i<<7);
ulong w[80]={0};
for (int j=0; j<16; j++) w[j]=SHA2_PACK64(sub_block, j<<3);
for (int j=16; j<80; j++) w[j]=SHA512_F4(w[j-2])+w[j-7]+SHA512_F3(w[j-15])+w[j-16];
ulong wv[8]={0};
for (int j=0; j<8; j++) wv[j]=m_h[j];
for (int j=0; j<80; j++)
{
ulong t1=wv[7]+SHA512_F2(wv[4])+SHA2_CH(wv[4], wv[5], wv[6])+sha512_k[j]+w[j];
ulong t2=SHA512_F1(wv[0])+SHA2_MAJ(wv[0], wv[1], wv[2]);
wv[7]=wv[6];
wv[6]=wv[5];
wv[5]=wv[4];
wv[4]=wv[3]+t1;
wv[3]=wv[2];
wv[2]=wv[1];
wv[1]=wv[0];
wv[0]=t1+t2;
}
for (int j=0; j<8; j++) m_h[j]+=wv[j];
}
}
void SHA2_UNPACK32(uint x, uchar& str[], int s)
{
str[s+3]=uchar(x);
str[s+2]=uchar(x>>8);
str[s+1]=uchar(x>>16);
str[s+0]=uchar(x>>24);
}
void SHA2_UNPACK64(ulong x, uchar& str[], int s)
{
str[s+7]=uchar(x);
str[s+6]=uchar(x>>8);
str[s+5]=uchar(x>>16);
str[s+4]=uchar(x>>24);
str[s+3]=uchar(x>>32);
str[s+2]=uchar(x>>40);
str[s+1]=uchar(x>>48);
str[s+0]=uchar(x>>56);
}
ulong SHA2_PACK64(uchar& str[], int s)
{
  ulong x=ulong(str[s+7]) | (ulong(str[s+6])<<8) | (ulong(str[s+5])<<16) | (ulong(str[s+4])<<24) | (ulong(str[s+3])<<32) | (ulong(str[s+2])<<40) | (ulong(str[s+1])<<48) | (ulong(str[s+0])<<56);
  return x;
}

public:
static string sha512(string in) { uchar out[]; return sha512(in, out); }
static string sha512(string in, uchar& out[]) { uchar cin[]; StringToCharArray(in, cin, 0, StringLen(in)); return sha512(cin, out); }
static string sha512(const uchar& in[]) { uchar out[]; return sha512(in, out); }
static string sha512(const uchar& in[], uchar& out[])
{
SHA512 sha;
sha.init();
sha.update(in, ArraySize(in));
uchar digest[DIGEST_SIZE]={0};
sha.end(digest);
string str; ArrayResize(out, DIGEST_SIZE);
for (int i=0; i<DIGEST_SIZE; i++) { str+=StringFormat("%02x", digest[i]); out[i]=digest[i]; }
return str;
}

static string hmac(string smsg, string skey)
{
uint BLOCKSIZE=SHA384_512_BLOCK_SIZE;
if ((uint)StringLen(skey)>BLOCKSIZE) skey=sha512(skey);
uchar key[]; uint n=(uint)StringToCharArray(skey, key, 0, StringLen(skey));
if (n<BLOCKSIZE) { ArrayResize(key, BLOCKSIZE); ArrayFill(key, n, BLOCKSIZE-n, 0); }

uchar i_key_pad[]; ArrayCopy(i_key_pad, key); for(uint i=0; i<BLOCKSIZE; i++) i_key_pad[i]=key[i]^(uchar)0x36;
uchar o_key_pad[]; ArrayCopy(o_key_pad, key); for(uint i=0; i<BLOCKSIZE; i++) o_key_pad[i]=key[i]^(uchar)0x5c;

uchar msg[]; n=(uint)StringToCharArray(smsg, msg, 0, StringLen(smsg));
uchar i_s[]; ArrayResize(i_s, BLOCKSIZE+n); ArrayCopy(i_s, i_key_pad); ArrayCopy(i_s, msg, BLOCKSIZE);
uchar i_sha512[]; string is=sha512(i_s, i_sha512);
uchar o_s[]; ArrayResize(o_s, BLOCKSIZE+ArraySize(i_sha512)); ArrayCopy(o_s, o_key_pad); ArrayCopy(o_s, i_sha512, BLOCKSIZE);
string o_sha512=sha512(o_s);

return o_sha512;
}

};

ulong SHA512::sha512_k[80]=
            {0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538, 0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118,
             0xd807aa98a3030242, 0x12835b0145706fbe, 0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235, 0xc19bf174cf692694,
             0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65, 0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5,
             0x983e5152ee66dfab, 0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725, 0x06ca6351e003826f, 0x142929670a0e6e70,
             0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed, 0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
             0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218, 0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8,
             0x19a4c116b8d2d0c8, 0x1e376c085141ab53, 0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373, 0x682e6ff3d6b2b8a3,
             0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec, 0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b,
             0xca273eceea26619c, 0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6, 0x113f9804bef90dae, 0x1b710b35131c471b,
             0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc, 0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817};

//------------------------------------------------------------------ OnStart
