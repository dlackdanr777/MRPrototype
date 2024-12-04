﻿using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using TMPro;

namespace NekoLegends
{
    public class NekoDemo : DemoScenes
    {

        [SerializeField] private Neko NekoCharacter;
        [SerializeField] private GameObject GoldCoin;

        [Space]
        [SerializeField] private Button PoseBtn;
        [SerializeField] private Button CameraBtn;
        [SerializeField] private Button RotateBtn;
        [Space]
        [SerializeField] private Button NextFeatureBtn;

        [Space]
        [SerializeField] private Transform MainCamTransform;
        [SerializeField] private Transform ZoomedCamTransform;


        [SerializeField] private GameObject PointLight;
        private bool isRotating;
        private const string _title = "Cel Shader Demo";

        #region Singleton
        public static new NekoDemo Instance
        {
            get
            {
                if (_instance == null)
                    _instance = Object.FindFirstObjectByType(typeof(NekoDemo)) as NekoDemo;

                return _instance;
            }
            set
            {
                _instance = value;
            }
        }
        private static NekoDemo _instance;
        #endregion

        #region Button listeners setup
        protected override void OnEnable()
        {
            base.OnEnable();
            PoseBtn.onClick.AddListener(PoseBtnClicked);
            CameraBtn.onClick.AddListener(CameraBtnClicked);
            RotateBtn.onClick.AddListener(RotateBtnClicked);

            NextFeatureBtn.onClick.AddListener(NextBtnClicked);

        }

        protected override void OnDisable()
        {
            base.OnDisable();
            PoseBtn.onClick.RemoveListener(PoseBtnClicked);
            CameraBtn.onClick.RemoveListener(CameraBtnClicked);
            RotateBtn.onClick.RemoveListener(RotateBtnClicked);
            NextFeatureBtn.onClick.RemoveListener(NextBtnClicked);
        }
        #endregion

        protected override void Start()
        {
            base.Start();

            CameraBtnClicked();//start zoomed since small neko
            GoldCoin.SetActive(false);
            DescriptionText.SetText(_title);
        }


        private void NextBtnClicked()
        {
            int featureIndex = NekoCharacter.ShowNextFeature();

            if (featureIndex == (NekoCharacter.GetFeatureCount()-1)) //completed, then show gold normals
            {
                this.NekoCharacter.gameObject.SetActive(false);
                this.GoldCoin.SetActive(true);
                this.DescriptionText.SetText("Texture Normals");
                if (!isRotating)
                    isRotating = true;

            }
            else if (featureIndex == 0)
            {
                this.NekoCharacter.gameObject.SetActive(true);
                this.GoldCoin.SetActive(false);
                this.NekoCharacter.transform.SetLocalPositionAndRotation(Vector3.zero, Quaternion.identity);
                isRotating = false;
            }
        }


        private void RotateBtnClicked()
        {
            isRotating = !isRotating;
        }

        private void PoseBtnClicked()
        {
            NekoCharacter.NextPose();
        }

        private void CameraBtnClicked()
        {
            FlyToNextCameraHandler();
        }


        public void SetBackgroundActive(bool isOn)
        {
            BGTransform.gameObject.SetActive(isOn);
        }

        public void SetPointLightActive(bool isOn)
        {
            PointLight.SetActive(isOn);
        }

        void Update()
        {
            if (isRotating)
            {
                float rotationSpeed = 50f;
                NekoCharacter.transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
                GoldCoin.transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
            }
        }

    }
}
