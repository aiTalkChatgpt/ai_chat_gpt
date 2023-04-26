package com.example.ai_chat_gpt;

import android.os.Bundle;
import android.os.Handler;

import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechSynthesizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.SynthesizerListener;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Objects;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private SpeechRecognizer mIat;          // 语音识别对象
    private SpeechSynthesizer mTts;         // 语音合成对象
    boolean flag = true;
    private Handler handler;

    private MethodChannel.Result mResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SpeechUtility.createUtility(this, SpeechConstant.APPID +"=5e0dbe0f");
        // 创建语音识别对象
        mIat = SpeechRecognizer.createRecognizer(this, null);
        // 设置听写参数
        mIat.setParameter(SpeechConstant.DOMAIN, "iat");
        mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
        mIat.setParameter(SpeechConstant.ACCENT, "mandarin");

        // 创建语音合成对象
        mTts = SpeechSynthesizer.createSynthesizer(this, null);
        // 设置语音合成参数
        mTts.setParameter(SpeechConstant.VOICE_NAME, "xiaoyan");
        mTts.setParameter(SpeechConstant.SPEED, "50");
        mTts.setParameter(SpeechConstant.VOLUME, "80");

        MethodChannel ListenChannel = new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), "my_app/listenChannel");
        MethodChannel speakChannel = new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), "my_app/speakChannel");
        MethodChannel stopChannel = new MethodChannel(Objects.requireNonNull(getFlutterEngine()).getDartExecutor().getBinaryMessenger(), "my_app/stopChannel");
        ListenChannel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("openListening")) {
                            flag = true;
                            mResult = result;
                            mIat.startListening(mRecognizerListener);
                        } else {
                            result.notImplemented();
                        }
                    }
                });

        speakChannel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("openSpeak")) {
                            mResult = result;
                            String param = call.argument("arg");
                            mTts.startSpeaking(param, mSynthesizerListener);
                        } else {
                            result.notImplemented();
                        }
                    }
                });
        stopChannel.setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("stop")) {
                            mResult = result;
                            mTts.stopSpeaking();
                            mIat.stopListening();
                        } else {
                            result.notImplemented();
                        }
                    }
                });

    }
    private RecognizerListener mRecognizerListener = new RecognizerListener() {
        // 开始录音
        @Override
        public void onBeginOfSpeech() {
        }

        // 结束录音
        @Override
        public void onEndOfSpeech() {
            // 在这里添加结束录音的代码
        }

        // 返回结果
        @Override
        public void onResult(RecognizerResult results, boolean isLast) {
            if (flag) {
                flag = false;
                String result = parseIatResult(results.getResultString());
                // 在这里添加将结果传递给语音合成引擎的代码
                mResult.success(result);
            }
        }

        // 返回错误
        @Override
        public void onError(SpeechError error) {
            // 在这里添加处理错误的代码
        }

        // 返回音量
        @Override
        public void onVolumeChanged(int volume, byte[] data) {
            // 在这里添加处理音量变化的代码
        }

        // 返回扩展结果
        @Override
        public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
            // 在这里添加处理扩展结果的代码
        }
    };

    private String parseIatResult(String json) {
        StringBuilder sb = new StringBuilder();
        try {
            JSONObject jsonObj = new JSONObject(json);
            JSONArray words = jsonObj.getJSONArray("ws");
            for (int i = 0; i < words.length(); i++) {
                JSONArray items = words.getJSONObject(i).getJSONArray("cw");
                for (int j = 0; j < items.length(); j++) {
                    sb.append(items.getJSONObject(j).getString("w"));
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return sb.toString();
    }



    // 语音合成监听器
    // 语音合成监听器
    private SynthesizerListener mSynthesizerListener = new SynthesizerListener() {
        // 开始播放
        @Override
        public void onSpeakBegin() {
            // 在这里添加开始播放的代码
        }

        // 播放进度
        @Override
        public void onSpeakProgress(int i, int i1, int i2) {
            // 在这里添加处理播放进度的代码
        }

        // 播放暂停
        @Override
        public void onSpeakPaused() {
            // 在这里添加处理播放暂停的代码
        }

        // 继续播放
        @Override
        public void onSpeakResumed() {
            // 在这里添加处理继续播放的代码
        }

        // 播放完成
        @Override
        public void onCompleted(SpeechError speechError) {
            flag = true;
            mResult.success("播放完成");
        }

        @Override
        public void onEvent(int i, int i1, int i2, Bundle bundle) {

        }

        // 缓冲进度
        @Override
        public void onBufferProgress(int i, int i1, int i2, String s) {
            // 在这里添加处理缓冲进度的代码
        }


    };
}

