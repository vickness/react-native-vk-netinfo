/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View} from 'react-native';
import NetInfo from './lib/index';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
export default class App extends Component<Props> {

  async getNetInfo() {

    const res1 = await NetInfo.isVPNConnected();
    const res2 = await NetInfo.getCarrierName();
    const res3 = await NetInfo.getIpsFromHost('www.baidu.com');

    console.warn("VPN检测："+res1);
    console.warn("运营商："+res2);
    console.warn(res3);
  }

  componentDidMount() {

    NetInfo.isVPNConnected().then(res => {
      console.warn("VPN检测："+res);
    });

    NetInfo.getCarrierName().then(res => {
      console.warn("运营商："+res);
    });

    NetInfo.getIpsFromHost('www.baidu.com').then(res => {
      console.warn(res);
    });

    this.getNetInfo();
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
