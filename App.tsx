/**
 * ReveChat React Native iOS SDK — sample integration.
 *
 * Everything native lives in ios/ReveChatDemo/ReveChatSDKModule.{swift,m}.
 * From JavaScript the SDK is just one method call.
 */

import React from 'react';
import {
  Alert,
  NativeModules,
  Platform,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
// react-native's own SafeAreaView is deprecated in 0.88; the template ships
// react-native-safe-area-context as the replacement.
import {SafeAreaProvider, SafeAreaView} from 'react-native-safe-area-context';

const {ReveChatSDKModule} = NativeModules;

// Replace with your own account id from the REVE Chat dashboard.
const ACCOUNT_ID = '2552651';

const VISITOR = {
  name: 'ahad',
  email: 'ahad@gmail.com',
  phone: '123123123',
};

function App(): React.JSX.Element {
  const startChat = async () => {
    if (Platform.OS !== 'ios') {
      Alert.alert('iOS only', 'This sample integrates the ReveChat iOS SDK.');
      return;
    }

    if (!ReveChatSDKModule) {
      Alert.alert(
        'Native module missing',
        'ReveChatSDKModule was not found. Run "pod install" in ios/ and rebuild from Xcode.',
      );
      return;
    }

    try {
      await ReveChatSDKModule.startChat(
        ACCOUNT_ID,
        VISITOR.name,
        VISITOR.email,
        VISITOR.phone,
      );
    } catch (error: any) {
      Alert.alert('Could not open chat', error?.message ?? String(error));
    }
  };

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="dark-content" />
        <View style={styles.content}>
          <Text style={styles.title}>ReveChat SDK</Text>
          <Text style={styles.subtitle}>React Native iOS sample</Text>

          <TouchableOpacity
            style={styles.button}
            onPress={startChat}
            activeOpacity={0.8}>
            <Text style={styles.buttonText}>Start Chat</Text>
          </TouchableOpacity>

          <Text style={styles.note}>
            Account {ACCOUNT_ID} · run on a physical device
          </Text>
        </View>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: '#ffffff'},
  content: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  title: {fontSize: 28, fontWeight: '700', color: '#1a1a1a'},
  subtitle: {fontSize: 15, color: '#6b6b6b', marginTop: 6, marginBottom: 40},
  button: {
    backgroundColor: '#f28722',
    paddingVertical: 14,
    paddingHorizontal: 44,
    borderRadius: 10,
  },
  buttonText: {color: '#ffffff', fontSize: 17, fontWeight: '600'},
  note: {fontSize: 13, color: '#8a8a8a', marginTop: 28},
});

export default App;
