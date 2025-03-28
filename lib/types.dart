enum DataLoadingStatus{
  none,
  loading,
  loaded
}

// class
//
typedef ResponseHandler = String Function();

const userCaptchaCode = 0;
const phoneCaptchaCode = 1;
const emailCaptchaCode = 2;