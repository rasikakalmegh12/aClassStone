class LogoutRequestBody {
  String? browsername;
  String? browserversion;
  String? opersatingsystem;
  String? osversion;
  String? loginby;
  String? lasthittime;
  String? pagename;
  String? apiversion;
  String? remarks;

  LogoutRequestBody(
      {this.browsername,
        this.browserversion,
        this.opersatingsystem,
        this.osversion,
        this.loginby,
        this.lasthittime,
        this.pagename,
        this.apiversion,
        this.remarks});

  LogoutRequestBody.fromJson(Map<String, dynamic> json) {
    browsername = json['browsername'];
    browserversion = json['browserversion'];
    opersatingsystem = json['opersatingsystem'];
    osversion = json['osversion'];
    loginby = json['loginby'];
    lasthittime = json['lasthittime'];
    pagename = json['pagename'];
    apiversion = json['apiversion'];
    remarks = json['remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['browsername'] = this.browsername;
    data['browserversion'] = this.browserversion;
    data['opersatingsystem'] = this.opersatingsystem;
    data['osversion'] = this.osversion;
    data['loginby'] = this.loginby;
    data['lasthittime'] = this.lasthittime;
    data['pagename'] = this.pagename;
    data['apiversion'] = this.apiversion;
    data['remarks'] = this.remarks;
    return data;
  }
}
