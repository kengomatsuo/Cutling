Source: https://developer.apple.com/forums/thread/833575 , read in Chrome get_page_text 2026-11-21. Thread "Using FoundationModels framework in Extensions", Machine Learning & AI / Foundation Models, created Jun 2026 by "taheri", 2 replies.

Question: LLMs use so much RAM; does this mean FoundationModels cannot be used in extensions such as MessageFilterExtension? Assumes the system kills the extension before a response.

Answer by DTS Engineer Ziqiao Chen (Worldwide Developer Relations), Jun 2026:
"The system language model (SystemLanguageModel) is not loaded into the app / extension's memory, and so using it doesn't count on the memory limit of your extension. If you are using your own on-device model, the model will be loaded to the memory of your app / extension, and so you will need to test if that is fine for your extension. Note that some extensions don't allow XPC due to privacy reason, and hence can't use a model via the Foundation Models framework."

Follow-up by OP, Jun 2026: "Does this include SystemLanguageModel?" regarding the XPC sentence. No reply shown on the page (page shows 2 replies: the DTS answer and this follow-up).

Not said anywhere in the thread: whether a keyboard extension (with or without Full Access) may call the system model. UNSURE.
