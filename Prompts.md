<h1>A S M Hossain Mahmmud Shadhin (68)  🛜<i><b>Networking</b></i></h1> 

<ol>
  <li>Flutter দিয়ে একটি সুন্দর Home Screen তৈরি করো যেটা দেখতে নিচের মতো হবে:

১.⁠ ⁠ব্যাকগ্রাউন্ড কালার: পুরো স্ক্রিনের ব্যাকগ্রাউন্ড হবে গাঢ় নেভি ব্লু (Dark Navy Blue), যেমন Color(0xFF0D1B3E) বা Color(0xFF0A1628)।

২.⁠ ⁠উপরের লোগো সেকশন:

স্ক্রিনের একদম উপরে মাঝখানে একটি গোলাকার লোগো থাকবে।
লোগোটির চারপাশে একটি সাদা বর্ডার (circular border) থাকবে।
ভেতরে WCWI-এর লোগো ইমেজ থাকবে (assets/logo.png)।
লোগোর সাইজ হবে প্রায় 100x100 বা 120x120 pixel।
৩.⁠ ⁠টাইটেল কার্ড:

লোগোর নিচে একটি ডার্ক কার্ড থাকবে (কিছুটা লোগোর পেছনে overlap করবে)।
কার্ডের ব্যাকগ্রাউন্ড হবে গাঢ় রঙ, যেমন Color(0xFF1A2744)।
কার্ডের ভেতরে বড় করে লেখা থাকবে "WCWI" — কালার হবে হালকা নীল/সায়ান (Color(0xFF4DD0E1) বা Colors.cyan)।
তার নিচে ছোট করে লেখা থাকবে "Wireless Communication Without Internet" — কালার হবে হালকা ধূসর সাদা।
কার্ডের কর্নার গোলাকার থাকবে (BorderRadius ~16)।
৪.⁠ ⁠"Choose Connection Mode" বাটন:

টাইটেল কার্ডের নিচে একটি ছোট pill/capsule আকৃতির বাটন থাকবে।
বাটনের বাম দিকে একটি হলুদ বা কমলা ছোট dot/circle থাকবে।
বাটনে লেখা থাকবে "Choose connection mode" — রঙ সাদা।
বাটনের ব্যাকগ্রাউন্ড হবে ট্রান্সপারেন্ট বা ডার্ক, border থাকবে।
৫.⁠ ⁠"Select Connection Mode" হেডিং:

বাটনের নিচে বড় করে "Select Connection Mode" লেখা থাকবে।
ফন্ট সাইজ ~22, ওজন Bold, কালার সাদা।
৬.⁠ ⁠তিনটি মোড কার্ড (Main Feature Cards): তিনটি আলাদা রঙের বড় কার্ড থাকবে, প্রতিটিতে বাম দিকে আইকন, ডান দিকে টাইটেল ও সাবটাইটেল থাকবে:

WiFi Mode কার্ড:
Gradient: বেগুনি থেকে নীল (Purple → Blue)
আইকন: Icons.wifi (সাদা রঙ)
টাইটেল: "WiFi Mode" (Bold, সাদা)
সাবটাইটেল: "Connect via Local WiFi Access Point or Hotspot" (হালকা সাদা)
Bluetooth Mode কার্ড:
Gradient: নীল থেকে সায়ান (Blue → Cyan)
আইকন: Icons.bluetooth (সাদা রঙ)
টাইটেল: "Bluetooth Mode" (Bold, সাদা)
সাবটাইটেল: "Connect directly offline using Bluetooth paired devices"
Chat History কার্ড:
Gradient: গোলাপি থেকে লাল (Pink → Red/Coral)
আইকন: Icons.history বা Icons.chat_bubble (সাদা)
টাইটেল: "Chat History" (Bold, সাদা)
সাবটাইটেল: "View & manage offline messages, audio & photos"
৭.⁠ ⁠কার্ডের ডিজাইন স্পেসিফিকেশন:

প্রতিটি কার্ডের height হবে ~80-90 pixel।
BorderRadius: ~16 বা ~20।
কার্ডগুলোর মধ্যে ~12-16px gap থাকবে।
প্রতিটি কার্ডে InkWell বা GestureDetector দিয়ে onTap কাজ করবে।
কার্ডে padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)।
৮.⁠ ⁠লেআউট:

সব কিছু Column এর মধ্যে থাকবে, SingleChildScrollView দিয়ে wrap করা।
লোগো ও কার্ড overlap করতে Stack widget ব্যবহার করো।
সম্পূর্ণ স্ক্রিন SafeArea দিয়ে wrap করো।
Horizontal padding: ~20px।
৯.⁠ ⁠ফন্ট ও অ্যানিমেশন (optional কিন্তু সুন্দর দেখাবে):

Google Fonts থেকে "Poppins" বা "Inter" ফন্ট ব্যবহার করো।
কার্ডগুলোতে hover/tap এ হালকা scale animation যোগ করো।</li>
<li></li>
</ol>
<h1>Faiyaz Karim Annoor (69) </h1>

<ol>
  <li></li>
</ol>
<h1>Pranto Roy (70)</h1>

<ol>
  <li></li>
</ol>
