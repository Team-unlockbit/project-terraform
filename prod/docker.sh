#!/bin/bash

# 헬프 메시지 함수
function display_help {
    echo "사용법: $0 [ECR_URI] [IMAGE_NAME] [IMAGE_TAG]"
    echo
    echo "ECR_URI    AWS ECR 리포지토리 URI를 입력합니다."
    echo "IMAGE_TAG  (선택) Docker 이미지 태그를 입력합니다. 기본값은 'latest'입니다."
    exit 1
}

# 인자 유효성 검사
if [ $# -lt 1 ]; then
    display_help
fi

# 인자 설정
ECR_URI=$1
IMAGE_NAME=$2
IMAGE_TAG=${3:-latest}  # 두 번째 인자를 사용하거나, 없으면 기본값 'latest' 사용

# AWS 리전 추출 (URI에서 추출하거나 직접 설정)
AWS_REGION=$(echo $ECR_URI | cut -d'.' -f4)

# AWS ECR 로그인
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

# Docker 이미지 빌드
#docker build -t $ECR_URI:$IMAGE_TAG .
docker pull $IAMGE_NAME:$IMAGE_TAG

# Docker 이미지 태그
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

# Docker 이미지 ECR에 푸시
docker push $ECR_URI:$IMAGE_TAG

echo "이미지가 성공적으로 ECR에 업로드되었습니다: $ECR_URI:$IMAGE_TAG"

