//响应成功码
const responseCodeOk = 200;
// 在使用API接口时，若密码过期，认证成功时返回240状态码
const passwordExpired = 240;
// 若密码过期且要求强制更新，认证成功时返回241状态码，且其它接口均必须要在密码修改后才能调用
const passwordExpiredForce = 241;
// 若系统要求不能使用自动密码，且用户从未设置密码，认证成功时返回242状态码，且其它接口均必须要在密码设置后才能调用
const passwordSetForce = 242;

// JWT状态码：JWT过期
const jwtCodeExpired = 450;

const textPlainResponse = "text/plain; charset=utf-8";
const protobufResponse = "application/base64+protobuf";