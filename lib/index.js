
import { NativeModules } from 'react-native';

const { RNNetInfo } = NativeModules;

export default class NetInfo {

    /** 是否连接VPN*/
    static isVPNConnected() {
        return RNNetInfo.isVPNConnected();
    }

    /** 查询运营商*/
    static getCarrierName() {
        return RNNetInfo.getCarrierName();
    }

    /** 域名转IP地址列表*/
    static getIpsFromHost(host) {
        return RNNetInfo.getIpsFromHost(host);
    }
}
