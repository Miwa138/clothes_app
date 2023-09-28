class API
{
  static const hostConnect = "http://host1373377.hostland.pro/api_clothes_store";
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectAdmin = "$hostConnect/admin";
  static const hostUploadItem = "$hostConnect/items";
  static const hostloadItem = "$hostConnect/items";
  static const hostloadRating = "$hostConnect/rating";
  static const hostloadOptions = "$hostConnect/options";
  static const hostloadOptionsRatingTime = "$hostConnect/options";

  // Регитсрация пользователя

static const validateEmail = "$hostConnectUser/validate_email.php";
static const signUp = "$hostConnectUser/signup.php";
static const login = "$hostConnectUser/login.php";
static const adminlogin = "$hostConnectAdmin/login.php";
static const uploadNewItem = "$hostUploadItem/uploaded.php";
static const loadNewItem = "$hostloadItem/loaded.php";
static const updateRating = "$hostloadRating/rating.php";
static const updateOptions = "$hostloadOptions/options.php";
static const updateOptionRatingTime = "$hostloadOptionsRatingTime/get_rating_time.php";
}
