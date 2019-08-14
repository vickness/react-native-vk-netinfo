
package com.reactlibrary;

import android.content.Context;
import android.telephony.TelephonyManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Collections;
import java.util.Enumeration;

public class RNNetInfoModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNNetInfoModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNNetInfo";
  }


  /** 检测是否连接VPN*/
  @ReactMethod
  public void isVPNConnected(final Promise promise) {

    Boolean isVPN = false;

    try {

      Enumeration<NetworkInterface> niList = NetworkInterface.getNetworkInterfaces();

      if (niList != null) {

        for (NetworkInterface intf : Collections.list(niList)) {

          if (!intf.isUp() || intf.getInterfaceAddresses().size() == 0) {

            continue;
          }

          if ("tun0".equals(intf.getName()) || "ppp0".equals(intf.getName())) {
            isVPN = true; // The VPN is up
          }
        }
      }

    } catch (Throwable e) {

    }

    promise.resolve(isVPN);
  }


  /** 获取运营商名称*/
  @ReactMethod
  public void getCarrierName(final Promise promise) {
    TelephonyManager telMgr = (TelephonyManager) this.reactContext.getSystemService(Context.TELEPHONY_SERVICE);
    String carrierName = telMgr.getNetworkOperatorName();
    promise.resolve(carrierName);
  }


  /** 将域名转化为IP地址*/
  @ReactMethod
  public void getIpsFromHost(final String hostname, final Promise promise) {

    if (hostname == null || promise == null) {
      promise.reject(new Error("hostname or promise cannot be null"));
    }

    try {
      InetAddress[] rawAddresses = InetAddress.getAllByName(hostname);
      WritableArray addresses = Arguments.createArray();
      for (int i = 0; i < rawAddresses.length; i++) {
        addresses.pushString(rawAddresses[i].getHostAddress());
      }
      promise.resolve(addresses);
    } catch (Exception e) {
      promise.resolve(null);
    }
  }
}
