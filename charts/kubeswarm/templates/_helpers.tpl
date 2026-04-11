{{/*
Expand the name of the chart.
*/}}
{{- define "kubeswarm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kubeswarm.fullname" -}}
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
Create chart label.
*/}}
{{- define "kubeswarm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "kubeswarm.labels" -}}
helm.sh/chart: {{ include "kubeswarm.chart" . }}
{{ include "kubeswarm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "kubeswarm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubeswarm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "kubeswarm.serviceAccountName" -}}
{{- .Values.serviceAccount.name | default (include "kubeswarm.fullname" .) }}
{{- end }}

{{/*
Operator image.
*/}}
{{- define "kubeswarm.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Task queue URL. Required - the operator needs a queue backend to dispatch tasks.
*/}}
{{- define "kubeswarm.queueURL" -}}
{{- required "taskQueueURL is required" .Values.taskQueueURL -}}
{{- end }}

{{/*
Stream channel URL for SSE token streaming.
Defaults to taskQueueURL when not explicitly set.
*/}}
{{- define "kubeswarm.streamURL" -}}
{{- .Values.streamChannelURL | default (include "kubeswarm.queueURL" .) -}}
{{- end }}

{{/*
Spend store URL for budget tracking.
Defaults to taskQueueURL when not explicitly set.
*/}}
{{- define "kubeswarm.spendURL" -}}
{{- .Values.spendStoreURL | default (include "kubeswarm.queueURL" .) -}}
{{- end }}

{{/*
Audit log URL. Required when auditLog.sink is set to a backend that needs a URL.
*/}}
{{- define "kubeswarm.auditURL" -}}
{{- .Values.auditLog.redisURL -}}
{{- end }}

