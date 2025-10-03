from src.common.util import analyze
def test_analyze_limits(monkeypatch):
    class Fake:
        def detect_dominant_language(self, Text):
            return {"Languages": [{"LanguageCode": "en"}]}
        def detect_sentiment(self, Text, LanguageCode):
            return {"Sentiment":"NEUTRAL","SentimentScore":{"Positive":0,"Negative":0,"Neutral":1,"Mixed":0}}
        def detect_entities(self, Text, LanguageCode):
            return {"Entities":[]}
        def detect_key_phrases(self, Text, LanguageCode):
            return {"KeyPhrases":[]}
    import src.common.util as util
    util.comp = Fake()
    res = analyze("x"*6000)
    assert res["sentiment"] == "NEUTRAL"
