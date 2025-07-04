#!/bin/bash

echo "==============================================="
echo "   اختبار API - تطبيق البروج العقاري"
echo "==============================================="
echo

echo "[1/4] اختبار حالة API..."
curl -X GET "https://albrog.com/api/" -H "Accept: application/json" 2>/dev/null | jq . || curl -X GET "https://albrog.com/api/" -H "Accept: application/json"
echo
echo

echo "[2/4] اختبار العقارات المميزة..."
curl -X GET "https://albrog.com/api/properties/featured?limit=3" -H "Accept: application/json" 2>/dev/null | jq . || curl -X GET "https://albrog.com/api/properties/featured?limit=3" -H "Accept: application/json"
echo
echo

echo "[3/4] اختبار العقارات الحديثة..."
curl -X GET "https://albrog.com/api/properties/recent?limit=3" -H "Accept: application/json" 2>/dev/null | jq . || curl -X GET "https://albrog.com/api/properties/recent?limit=3" -H "Accept: application/json"
echo
echo

echo "[4/4] اختبار البحث في العقارات..."
curl -X GET "https://albrog.com/api/properties/search?limit=2&type=villa" -H "Accept: application/json" 2>/dev/null | jq . || curl -X GET "https://albrog.com/api/properties/search?limit=2&type=villa" -H "Accept: application/json"
echo
echo

echo "==============================================="
echo "              انتهى الاختبار"
echo "==============================================="
echo
echo "إذا رأيت \"success\": true في جميع النتائج،"
echo "فإن API يعمل بشكل صحيح!"
echo
echo "الآن يمكنك تشغيل تطبيق Flutter:"
echo "flutter pub get"
echo "flutter run"
echo

read -p "اضغط Enter للمتابعة..." 