ARG ERIC_ENM_SLES_EAP7_IMAGE_NAME=eric-enm-sles-eap7
ARG ERIC_ENM_SLES_EAP7_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_EAP7_IMAGE_TAG=1.64.0-32

FROM ${ERIC_ENM_SLES_EAP7_IMAGE_REPO}/${ERIC_ENM_SLES_EAP7_IMAGE_NAME}:${ERIC_ENM_SLES_EAP7_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified
ARG SGUSER=111954

LABEL \
com.ericsson.product-number="CXC 999 9999" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM ebstopology Service Group" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

RUN zypper download  ERICenmsgebstopology_CXP9033328 && \
    zypper install -y ERICeap7config_CXP9037440 \
    ERICserviceframework4_CXP9037454 \
    ERICserviceframeworkmodule4_CXP9037453 \
    ERICmodelserviceapi_CXP9030594 \
    ERICmodelservice_CXP9030595 \
    ERICdpsruntimeapi_CXP9030469 \
    ERICdpsruntimeimpl_CXP9030468 \
    ERICpib2_CXP9037459 \
    ERICebstopologyservice_CXP9033327 && \
    rpm -ivh /var/cache/zypp/packages/enm_iso_repo/ERICenmsgebstopology_CXP9033328*.rpm --nodeps --noscripts --replacefiles && \
    zypper clean -a

COPY image_content/wait_for_applicationhealthstatus.sh /usr/lib/ocf/resource.d/
RUN chmod 755 /usr/lib/ocf/resource.d/wait_for_applicationhealthstatus.sh && \
rm /ericsson/3pp/jboss/bin/post-start/update_management_credential_permissions.sh \
   /ericsson/3pp/jboss/bin/post-start/update_standalone_permissions.sh 
RUN echo "$SGUSER:x:$SGUSER:$SGUSER:An Identity for ebstopology:/nonexistent:/bin/false" >>/etc/passwd && \
echo "$SGUSER:!::0:::::" >>/etc/shadow

ENV ENM_JBOSS_SDK_CLUSTER_ID="ebstopology" \
    ENM_JBOSS_BIND_ADDRESS="0.0.0.0" \
    JBOSS_CONF="/ericsson/3pp/jboss/jboss-as.conf" \
    CLOUD_DEPLOYMENT="TRUE"

EXPOSE 4712 4713 4447 8009 8080 8443 9990 9443 9999 54200 55200 57600

USER $SGUSER