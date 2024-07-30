{{/*
Expand the name of the chart.
*/}}
{{- define "geotax.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geotax.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geotax.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geotax.labels" -}}
helm.sh/chart: {{ include "geotax.chart" . }}
{{ include "geotax.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geotax.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geotax.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "geotax.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "geotax.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Storage Class Name
*/}}
{{- define "geotax-storage-class.name" -}}
{{- printf "%s-%s" .Release.Name "efs" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Name
*/}}
{{- define "geotax-pv.name" -}}
{{- printf "%s-%s" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Claim Name
*/}}
{{- define "geotax-pvc.name" -}}
{{- printf "%s-%s" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
VolumeMounts
*/}}
{{- define "geotax-svc.volumeMounts" -}}
- name: geotax-host-volume
  mountPath: {{ .Values.global.nfs.volumeMountPath }}
{{- end }}

{{/*
Common PV labels
*/}}
{{- define "geotax-pv.labels" -}}
app.kubernetes.io/name: {{ include "geotax-pv.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common PVC labels
*/}}
{{- define "geotax-pvc.labels" -}}
app.kubernetes.io/name: {{ include "geotax-pvc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Geotax data config map name
*/}}
{{- define "geotax-data-config.name" -}}
{{- if .Values.global.manualDataConfig.enabled }}
{{- printf "%s-%s" .Values.global.manualDataConfig.nameOverride .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" "geotax-data-mnt-config" }}
{{- end }}
{{- end }}



{{/*
Storage Class Name
*/}}
{{- define "geotax-hook-storage-class.name" -}}
{{- printf "%s-%s" "hook-efs" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Name
*/}}
{{- define "geotax-hook-pv.name" -}}
{{- printf "%s-%s-%s" "hook" .Release.Name "pv" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Persistent Volume Claim Name
*/}}
{{- define "geotax-hook-pvc.name" -}}
{{- printf "%s-%s-%s" "hook" .Release.Name "pvc" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common PV labels
*/}}
{{- define "geotax-hook-pv.labels" -}}
app.kubernetes.io/name: {{ include "geotax-hook-pv.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common PVC labels
*/}}
{{- define "geotax-hook-pvc.labels" -}}
app.kubernetes.io/name: {{ include "geotax-hook-pvc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}